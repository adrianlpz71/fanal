"""Precios automáticos. Cada tipo de activo tiene una fuente principal y otra de respaldo:

  · Fondos (por ISIN): FT (markets.ft.com, VL con su fecha) → quefondos.com → Yahoo Finance.
  · Cripto: CoinGecko → Kraken.
  · "manual": no se consulta nada.

Ninguna es oficial, así que: se usa la de respaldo si la principal falla, se descarta un precio
que se aleja más de un 25 % del último conocido (posible instrumento equivocado) y, si no hay
precio nuevo en varios días, la cartera lo marca como desactualizado. Nunca se inventa un precio.
"""

import logging
import re
from collections.abc import Callable
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal, InvalidOperation

import httpx
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.models import Asset, PriceHistory
from app.services import inversiones as svc

log = logging.getLogger("faro.prices")

UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130"
MAX_JUMP = Decimal("0.25")
MONTHS = {m: i + 1 for i, m in enumerate(
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
)}  # fmt: skip
KRAKEN_ALIASES = {"BTC": "XBT"}


class PriceError(Exception):
    pass


@dataclass(frozen=True)
class Quote:
    price: Decimal
    on: date
    currency: str
    source: str


def _dec(s: str) -> Decimal:
    try:
        return Decimal(s.replace(",", ""))
    except InvalidOperation:
        raise PriceError(f"precio ilegible: {s!r}") from None


# --- Fuentes -------------------------------------------------------------------------------
def ft_fund(client: httpx.Client, ref: str) -> Quote:
    """`ref` = "ISIN:EUR". El primer valor de la ficha es el VL; la fecha va en "as of"."""
    r = client.get("https://markets.ft.com/data/funds/tearsheet/summary", params={"s": ref},
                   follow_redirects=False)  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"FT HTTP {r.status_code}")
    html = r.text
    m = re.search(r'mod-ui-data-list__value">([0-9.,]+)<', html)
    cur = re.search(r"Price \(([A-Z]{3})\)", html)
    when = re.search(r"as of ([A-Z][a-z]{2}) (\d{1,2}) (\d{4})", html)
    if not (m and cur and when):
        raise PriceError("FT: formato de la ficha no reconocido")
    on = date(int(when.group(3)), MONTHS[when.group(1)], int(when.group(2)))
    return Quote(_dec(m.group(1)), on, cur.group(1), "ft")


def quefondos(client: httpx.Client, isin: str) -> Quote:
    """Ficha de quefondos.com: 'Valor liquidativo: 14,360100 EUR' y 'Fecha: 29/09/2026'."""
    r = client.get("https://www.quefondos.com/es/fondos/ficha/index.html", params={"isin": isin},
                   follow_redirects=True)  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"quefondos HTTP {r.status_code}")
    html = r.text
    m = re.search(r"Valor liquidativo:\s*</span>\s*<span[^>]*>\s*([0-9.,]+)\s*([A-Z]{3})", html)
    when = re.search(r"Fecha:\s*</span>\s*<span[^>]*>\s*(\d{2})/(\d{2})/(\d{4})", html)
    if not (m and when):
        raise PriceError("quefondos: formato de la ficha no reconocido")
    price = Decimal(m.group(1).replace(".", "").replace(",", "."))
    on = date(int(when.group(3)), int(when.group(2)), int(when.group(1)))
    return Quote(price, on, m.group(2), "quefondos")


def yahoo_fund(client: httpx.Client, isin: str, currency: str = "EUR") -> Quote:
    r = client.get("https://query2.finance.yahoo.com/v1/finance/search",
                   params={"q": isin, "quotesCount": 5, "newsCount": 0})  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"Yahoo búsqueda HTTP {r.status_code}")
    symbols = [q["symbol"] for q in r.json().get("quotes", [])
               if q.get("quoteType") in ("MUTUALFUND", "ETF")]  # fmt: skip
    for sym in symbols:
        c = client.get(f"https://query2.finance.yahoo.com/v8/finance/chart/{sym}",
                       params={"range": "5d", "interval": "1d"})  # fmt: skip
        if c.status_code != 200:
            continue
        meta = (c.json().get("chart", {}).get("result") or [{}])[0].get("meta", {})
        if meta.get("currency") != currency or meta.get("regularMarketPrice") is None:
            continue
        on = datetime.fromtimestamp(meta["regularMarketTime"], UTC).date()
        return Quote(_dec(str(meta["regularMarketPrice"])), on, currency, "yahoo")
    raise PriceError("Yahoo: sin cotización en " + currency)


def coingecko(client: httpx.Client, coin_id: str, currency: str = "EUR") -> Quote:
    vs = currency.lower()
    r = client.get("https://api.coingecko.com/api/v3/simple/price",
                   params={"ids": coin_id, "vs_currencies": vs,
                           "include_last_updated_at": "true"})  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"CoinGecko HTTP {r.status_code}")
    data = r.json().get(coin_id) or {}
    if vs not in data:
        raise PriceError(f"CoinGecko: {coin_id} desconocido")
    on = datetime.fromtimestamp(data.get("last_updated_at", 0) or datetime.now(UTC).timestamp(),
                                UTC).date()  # fmt: skip
    return Quote(_dec(str(data[vs])), on, currency, "coingecko")


def kraken(client: httpx.Client, ticker: str, currency: str = "EUR") -> Quote:
    base = KRAKEN_ALIASES.get(ticker.upper(), ticker.upper())
    r = client.get("https://api.kraken.com/0/public/Ticker", params={"pair": f"{base}{currency}"})
    body = r.json() if r.status_code == 200 else {}
    if body.get("error") or not body.get("result"):
        raise PriceError(f"Kraken: {body.get('error') or r.status_code}")
    last = next(iter(body["result"].values()))["c"][0]
    return Quote(_dec(last), datetime.now(UTC).date(), currency, "kraken")


# --- Orquestación --------------------------------------------------------------------------
def sources(asset: Asset) -> list[tuple[str, Callable[[httpx.Client], Quote]]]:
    if asset.price_provider == "ft":
        ref = asset.price_ref or (f"{asset.isin}:{asset.currency}" if asset.isin else None)
        out: list[tuple[str, Callable[[httpx.Client], Quote]]] = []
        if ref:
            out.append(("ft", lambda c: ft_fund(c, ref)))
        if asset.isin:
            out.append(("quefondos", lambda c: quefondos(c, asset.isin or "")))
            out.append(("yahoo", lambda c: yahoo_fund(c, asset.isin or "", asset.currency)))
        return out
    if asset.price_provider == "coingecko":
        out = []
        if asset.coingecko_id:
            out.append(
                ("coingecko", lambda c: coingecko(c, asset.coingecko_id or "", asset.currency))
            )
        if asset.ticker:
            out.append(("kraken", lambda c: kraken(c, asset.ticker or "", asset.currency)))
        return out
    return []


@dataclass
class Result:
    asset: Asset
    quote: Quote | None
    errors: list[str]


def fetch(client: httpx.Client, db: Session, asset: Asset) -> Result:
    errors: list[str] = []
    last = svc.latest_price(db, asset)
    for name, fn in sources(asset):
        try:
            q = fn(client)
        except (PriceError, httpx.HTTPError, ValueError, KeyError) as e:
            errors.append(f"{name}: {e}")
            continue
        if q.currency != asset.currency:
            errors.append(f"{name}: divisa {q.currency} ≠ {asset.currency}")
            continue
        if q.price <= 0:
            errors.append(f"{name}: precio no válido")
            continue
        if last and abs(q.price - last.price) / last.price > MAX_JUMP:
            errors.append(f"{name}: {q.price} se aleja más de un 25 % del último ({last.price})")
            continue
        return Result(asset, q, errors)
    if not sources(asset):
        errors.append("sin fuente configurada (ISIN o id de CoinGecko)")
    return Result(asset, None, errors)


def update(
    db: Session,
    user_id=None,
    client: httpx.Client | None = None,  # type: ignore[no-untyped-def]
) -> list[Result]:
    """Actualiza los precios de todos los activos con proveedor automático."""
    q = select(Asset).where(Asset.archived.is_(False), Asset.price_provider != "manual")
    if user_id is not None:
        q = q.where(Asset.user_id == user_id)
    own = client is None
    client = client or httpx.Client(timeout=15, headers={"User-Agent": UA})
    try:
        out = []
        for a in db.scalars(q):
            r = fetch(client, db, a)
            if r.quote:
                svc.set_price(db, a, r.quote.on, r.quote.price, r.quote.source, r.quote.currency)
                # El precio importado del Excel no tiene fecha real: el automático lo sustituye
                db.execute(delete(PriceHistory).where(
                    PriceHistory.asset_id == a.id, PriceHistory.source == "excel",
                    PriceHistory.date > r.quote.on,
                ))  # fmt: skip
            else:
                log.warning("price.failed", extra={"asset_type": a.type, "errors": len(r.errors)})
            out.append(r)
        db.flush()
        return out
    finally:
        if own:
            client.close()


def ecb_eur_per_usd(client: httpx.Client) -> Callable[[date], Decimal | None]:
    """Cambio oficial del BCE (API de datos del BCE, serie EXR D.USD.EUR). Para un día sin
    publicación (fin de semana, festivo) usa el último anterior. None si no responde."""
    usd_per_eur: dict[date, Decimal] = {}
    fetched_from: list[date] = []

    def load(since: date) -> None:
        try:
            r = client.get(
                "https://data-api.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A",
                params={"startPeriod": since.isoformat(), "format": "csvdata"},
            )
        except httpx.HTTPError:
            return
        if r.status_code != 200:
            return
        lines = r.text.splitlines()
        head = lines[0].split(",") if lines else []
        if "TIME_PERIOD" not in head or "OBS_VALUE" not in head:
            return
        ti, vi = head.index("TIME_PERIOD"), head.index("OBS_VALUE")
        for ln in lines[1:]:
            cells = ln.split(",")
            if len(cells) > max(ti, vi) and cells[vi]:
                usd_per_eur[date.fromisoformat(cells[ti])] = Decimal(cells[vi])
        fetched_from.append(since)

    def rate(d: date) -> Decimal | None:
        if not fetched_from or d < min(fetched_from):
            load(d - timedelta(days=10))
        known = [k for k in usd_per_eur if k <= d]
        return (1 / usd_per_eur[max(known)]) if known else None

    return rate


# --- Histórico (backfill) y composición de fondos -------------------------------------------------
FT_MONTHS = {m: i + 1 for i, m in enumerate(
    ["January", "February", "March", "April", "May", "June", "July", "August", "September",
     "October", "November", "December"]
)}  # fmt: skip


def ft_xid(client: httpx.Client, ref: str) -> str | None:
    """Identificador interno de FT de un fondo (lo pide su API de históricos)."""
    r = client.get("https://markets.ft.com/data/funds/tearsheet/historical", params={"s": ref},
                   follow_redirects=False)  # fmt: skip
    m = re.search(r"xid&quot;:&quot;(\d+)", r.text) if r.status_code == 200 else None
    return m.group(1) if m else None


def ft_history(
    client: httpx.Client, ref: str, start: date, end: date
) -> list[tuple[date, Decimal]]:
    """Valores liquidativos diarios de FT entre dos fechas (en tramos de 180 días)."""
    xid = ft_xid(client, ref)
    if xid is None:
        raise PriceError("FT: no encuentro el fondo para el histórico")
    out: dict[date, Decimal] = {}
    cur = start
    while cur <= end:
        to = min(end, cur + timedelta(days=180))
        params = {"startDate": cur.strftime("%Y/%m/%d"), "endDate": to.strftime("%Y/%m/%d"),
                  "symbol": xid}  # fmt: skip
        r = client.get("https://markets.ft.com/data/equities/ajax/get-historical-prices",
                       params=params)  # fmt: skip
        if r.status_code != 200:
            raise PriceError(f"FT histórico HTTP {r.status_code}")
        rows = re.findall(r"<tr>(.*?)</tr>", r.json().get("html", ""), re.S)
        for row in rows:
            d = re.search(r"(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), "
                          r"(\w+) (\d{1,2}), (\d{4})", row)  # fmt: skip
            nums = re.findall(r"<td>([0-9.,]+)</td>", row)
            if d and len(nums) >= 4 and d.group(1) in FT_MONTHS:
                on = date(int(d.group(3)), FT_MONTHS[d.group(1)], int(d.group(2)))
                out[on] = _dec(nums[3])  # cierre
        cur = to + timedelta(days=1)
    return sorted(out.items())


def coingecko_history(client: httpx.Client, coin_id: str, days: int, currency: str = "EUR"
                      ) -> list[tuple[date, Decimal]]:  # fmt: skip
    """Precio diario (00:00 UTC) de los últimos `days` días (máx. 365 en el plan gratuito)."""
    r = client.get(f"https://api.coingecko.com/api/v3/coins/{coin_id}/market_chart",
                   params={"vs_currency": currency.lower(), "days": min(days, 365),
                           "interval": "daily"})  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"CoinGecko histórico HTTP {r.status_code}")
    out: dict[date, Decimal] = {}
    for ts, price in r.json().get("prices", []):
        out[datetime.fromtimestamp(ts / 1000, UTC).date()] = _dec(str(price))
    return sorted(out.items())


# Regiones de primer nivel de FT (lo demás de su tabla son países o zonas dentro de ellas)
FT_REGIONS = {"Americas", "Greater Asia", "Greater Europe"}  # las tres de Morningstar
# Nombres de FT (Morningstar) en español; lo que no esté aquí se guarda tal cual
ES_NAMES = {
    "Technology": "Tecnología", "Financial Services": "Servicios financieros",
    "Industrials": "Industria", "Healthcare": "Salud",
    "Communication Services": "Comunicaciones", "Consumer Cyclical": "Consumo cíclico",
    "Consumer Defensive": "Consumo defensivo", "Energy": "Energía", "Other": "Otros",
    "Basic Materials": "Materiales básicos", "Real Estate": "Inmobiliario",
    "Utilities": "Servicios públicos",
    "Americas": "América", "Greater Asia": "Asia", "Greater Europe": "Europa",
    "United States": "Estados Unidos", "Canada": "Canadá", "Latin America": "Latinoamérica",
    "Japan": "Japón", "Australasia": "Australasia", "Developed Asia": "Asia desarrollada",
    "Emerging Asia": "Asia emergente", "Eurozone": "Eurozona",
    "Europe - ex Euro": "Europa fuera del euro", "United Kingdom": "Reino Unido",
    "Emerging Europe": "Europa emergente", "Middle East": "Oriente Medio", "Africa": "África",
    "Africa/Middle East": "África y Oriente Medio",
}  # fmt: skip


@dataclass(frozen=True)
class Exposure:
    dimension: str  # sector | region | pais
    key: str
    weight: Decimal  # tanto por uno
    as_of: date | None


def ft_exposure(client: httpx.Client, ref: str) -> list[Exposure]:
    """Pesos por sector y por región/país de la ficha "holdings" de FT."""
    r = client.get("https://markets.ft.com/data/funds/tearsheet/holdings", params={"s": ref},
                   follow_redirects=False)  # fmt: skip
    if r.status_code != 200:
        raise PriceError(f"FT composición HTTP {r.status_code}")
    html = r.text
    i = html.find(">Weightings<")
    if i < 0:
        raise PriceError("FT: la ficha no trae composición")
    text = re.sub(r"<[^>]+>", "|", html[i : i + 20000])
    blocks = re.split(r"As of ", text)
    out: list[Exposure] = []
    for n, block in enumerate(blocks[:2]):  # 0 = sectores, 1 = regiones
        when = (
            re.match(r"([A-Z][a-z]{2}) (\d{1,2}) (\d{4})", blocks[n + 1])
            if n + 1 < len(blocks)
            else None
        )
        as_of = (
            date(int(when.group(3)), MONTHS[when.group(1)], int(when.group(2))) if when else None
        )
        for name, pct in re.findall(r"\|([A-Za-z][A-Za-z &/,.\-]+?)\|+(-?[0-9.]+)%\|", block):
            name = name.strip()
            if name in ("Sector", "Category average") or name.startswith("% "):
                continue
            dim = "sector" if n == 0 else ("region" if name in FT_REGIONS else "pais")
            weight = (Decimal(pct) / 100).quantize(Decimal("0.0001"))
            out.append(Exposure(dim, ES_NAMES.get(name, name), weight, as_of))
    if not out:
        raise PriceError("FT: no entiendo la composición")
    return out

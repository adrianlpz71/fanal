"""Precios automáticos con respuestas simuladas (sin red): principal, respaldo y salvaguardas."""

from datetime import date
from decimal import Decimal as D

import httpx
from sqlalchemy import select

from app.db import SessionLocal
from app.models import Asset, InvTransaction, User
from app.services import inversiones as svc
from app.services import prices as px

FT_HTML = """<html><span class="mod-ui-data-list__label">Price (EUR)</span>
<span class="mod-ui-data-list__value">14.32</span>
<div class="mod-disclaimer">Data delayed at least 15 minutes, as of Sep 30 2026.</div></html>"""


QF_HTML = """<span>Valor liquidativo: </span><span class="floatright">14,360100 EUR</span>
<span>Fecha: </span><span class="floatright">29/09/2026</span>"""


def transport(ft_ok=True, cg_ok=True, ft_price="14.32", qf_ok=True):
    def handler(req: httpx.Request) -> httpx.Response:
        host, path = req.url.host, req.url.path
        if host == "markets.ft.com":
            if not ft_ok:
                return httpx.Response(302)
            return httpx.Response(200, text=FT_HTML.replace("14.32", ft_price))
        if host == "www.quefondos.com":
            if not qf_ok:
                return httpx.Response(500)
            return httpx.Response(200, text=QF_HTML)
        if host == "query2.finance.yahoo.com" and path.endswith("/search"):
            return httpx.Response(200, json={"quotes": [
                {"symbol": "0PTEST.F", "quoteType": "MUTUALFUND"}]})  # fmt: skip
        if host == "query2.finance.yahoo.com":
            return httpx.Response(200, json={"chart": {"result": [{"meta": {
                "currency": "EUR", "regularMarketPrice": 14.36, "regularMarketTime": 1790712000,
            }}]}})  # fmt: skip
        if host == "api.coingecko.com":
            if not cg_ok:
                return httpx.Response(429)
            return httpx.Response(
                200, json={"bitcoin": {"eur": 75320, "last_updated_at": 1790882740}}
            )
        if host == "api.kraken.com":
            return httpx.Response(
                200, json={"error": [], "result": {"XXBTZEUR": {"c": ["75237.5", "1"]}}}
            )
        return httpx.Response(404)

    return httpx.Client(transport=httpx.MockTransport(handler))


def setup(db):
    u = db.scalar(select(User).where(User.email == "ana@example.com"))
    fund = Asset(user_id=u.id, name="MSCI", type="fondo", isin="IE00B03HCZ61",
                 price_provider="ft", price_ref="IE00B03HCZ61:EUR")  # fmt: skip
    btc = Asset(user_id=u.id, name="BTC", type="cripto", ticker="BTC", coingecko_id="bitcoin",
                price_provider="coingecko")  # fmt: skip
    manual = Asset(user_id=u.id, name="Acción A", type="accion", price_provider="manual")
    db.add_all([fund, btc, manual])
    db.flush()
    return u, fund, btc


def test_primary_sources(make_user):
    make_user()
    with SessionLocal() as db:
        _, fund, _btc = setup(db)
        res = {r.asset.name: r for r in px.update(db, client=transport())}
        assert set(res) == {"MSCI", "BTC"}  # el manual no se consulta
        assert (res["MSCI"].quote.price, res["MSCI"].quote.on) == (D("14.32"), date(2026, 9, 30))
        assert res["BTC"].quote.source == "coingecko"
        assert svc.latest_price(db, fund).price == D("14.32")


def test_fallbacks_and_jump_guard(make_user):
    make_user()
    with SessionLocal() as db:
        _, fund, _btc = setup(db)
        res = {r.asset.name: r for r in px.update(db, client=transport(ft_ok=False, cg_ok=False))}
        assert res["MSCI"].quote.source == "quefondos" and res["MSCI"].errors == ["ft: FT HTTP 302"]
        assert (res["MSCI"].quote.price, res["MSCI"].quote.on) == (
            D("14.360100"),
            date(2026, 9, 29),
        )
        r = px.fetch(transport(ft_ok=False, qf_ok=False), db, fund)
        assert r.quote.source == "yahoo" and len(r.errors) == 2
        assert res["BTC"].quote.source == "kraken"
        # Un salto > 25 % se descarta (posible instrumento equivocado) y se prueba la siguiente
        r = px.fetch(transport(ft_price="28.00"), db, fund)
        assert r.quote.source == "quefondos" and "25 %" in r.errors[0]


def test_auto_settle_with_nav_of_trade_date(make_user):
    make_user()
    with SessionLocal() as db:
        u, fund, _ = setup(db)
        tx = InvTransaction(user_id=u.id, asset_id=fund.id, kind="compra", status="pendiente_vl",
                            trade_date=date(2026, 9, 30), amount_eur=D("50"))  # fmt: skip
        db.add(tx)
        db.flush()
        px.update(db, client=transport())
        assert svc.auto_settle(db) == 1
        assert tx.status == "liquidada" and tx.units == D("3.4916")  # 50 / 14,32 truncado

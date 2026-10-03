"""Importadores de plataformas y extracto PDF con ficheros sintéticos (mismo formato que los
reales, datos inventados). Sin red: el cambio del BCE y el nombre del fondo se simulan."""

from datetime import date
from decimal import Decimal as D

import pytest

from app.importers import pdf_statements as pdfs
from app.importers import platforms as pf
from app.importers.tabular import read_table
from app.services import prices as px
from tests.conftest import auth_header, enroll

MYINVESTOR = """Fecha de la orden;ISIN;Importe estimado;Nº de participaciones;Estado
20/05/2026;FR0000000002;10 EUR;0,5;Finalizada
22/02/2025;FR0000000002;199.5 EUR;9,9;Finalizada
22/02/2025;IE0000000001;201.25 EUR;30,5;Finalizada
20/02/2025;IE0000000001;1 EUR;;Finalizada
18/10/2024;IE0000000001;49.4 EUR;;Cancelada
18/10/2024;IE0000000001;100 EUR;10,5;Finalizada
14/03/2024;IE0000000001;100 EUR;20;Finalizada
""".encode()

NV_HEAD = ",".join([
    "Type", "Date", "Amount received", "Asset received", "Amount sent", "Asset sent", "Fee",
    "Asset of the fee", "Description", "USD price of asset received", "USD price of asset sent",
    "USD price of fee asset", "Network", "Blockchain address", "Blockchain transaction hash", "ID",
])  # fmt: skip
NEVERLESS = (
    NV_HEAD
    + """
Deposit,2026-05-29T10:00:00Z,100,EUR,,,,,,1.25,,,,,,a1
Trade,2026-05-29T10:00:00Z,100,EURC,100,EUR,,,Auto-conversion when depositing fiat,1.25,1.25,,,,,a1
Trade,2026-05-29T10:01:00Z,0.002,BTC,100,EURC,,,,62500,1.25,,,,,b2
Deposit,2026-06-05T00:00:00Z,0.000001,BTC,,,,,Prime interest,50000,,,,,,c3
Deposit,2026-06-06T00:00:00Z,0.5,ETH,,,,,,2000,,,,,,d4
"""
).encode()


def test_myinvestor_detects_transfer_and_skips_bad_rows():
    p = pf.read(MYINVESTOR, "mi.csv")
    assert p.source == "myinvestor"
    kinds = [(o.on.isoformat(), o.kind, o.key, o.units, o.amount_eur) for o in p.ops]
    assert ("2025-02-22", "traspaso_salida", "IE0000000001", D("30.5"), D("201.25")) in kinds
    assert ("2025-02-22", "traspaso_entrada", "FR0000000002", D("9.9"), D("199.5")) in kinds
    assert len(p.ops) == 5  # cancelada fuera; la de 1 € sin participaciones, aviso
    assert any("sin participaciones" in w for w in p.warnings)
    out = next(o for o in p.ops if o.kind == "traspaso_salida")
    assert p.ops[out.pair].kind == "traspaso_entrada"


def test_neverless_buy_interest_and_ignored_rows():
    p = pf.read(NEVERLESS, "nv.csv", eur_per_usd=lambda d: D("0.8"))
    assert [(o.kind, o.key, o.units, o.amount_eur) for o in p.ops] == [
        ("compra", "BTC", D("0.002"), D("100")),
        ("recompensa", "BTC", D("0.000001"), D("0.0400")),  # 0,000001 × 50.000 $ × 0,8
    ]
    assert any("ETH desde fuera" in w for w in p.warnings)
    # Sin BCE: se usa el cambio del propio fichero (1 € = 1,25 $) y se avisa
    p2 = pf.read(NEVERLESS, "nv.csv", eur_per_usd=lambda d: None)
    assert p2.ops[1].amount_eur == D("0.0400") and any("BCE" in w for w in p2.warnings)


def test_unknown_file_is_rejected():
    with pytest.raises(pf.ImportFormatError):
        pf.detect(read_table(b"a;b;c\n1;2;3\n", "x.csv"))


TR_TEXT = """TRADE REPUBLIC BANK GMBH
RESUMEN DE ESTADO DE CUENTA
PRODUCTO BALANCE INICIAL ENTRADA DE DINERO SALIDA DE DINERO BALANCE FINAL
Cuenta corriente 10,00 € 1.100,00 € 50,00 € 1.060,00 €
TRANSACCIONES DE CUENTA
FECHA TIPO DESCRIPCIÓN ENTRADA DE
DINERO
SALIDA DE
DINERO BALANCE
02 mar
2026 Transferencia Incoming transfer from PERSONA (ES00) 1.100,00 € 1.110,00 €
05 mar
2026
Transacción
con tarjeta TIENDA, 10,00 $, exchange rate: 0,9 40,00 € 1.070,00 €
01 abr
2026 Interés Interest payment 0,50 € 1.070,50 €
02 abr
2026 Transferencia Outgoing transfer for PERSONA 10,50 € 1.060,00 €
RESUMEN DEL BALANCE
"""


def test_trade_republic_signs_from_balance():
    lines, warnings = pdfs.trade_republic(TR_TEXT)
    assert warnings == []
    assert [(ln.date, ln.amount) for ln in lines] == [
        (date(2026, 3, 2), D("1100.00")),
        (date(2026, 3, 5), D("-40.00")),
        (date(2026, 4, 1), D("0.50")),
        (date(2026, 4, 2), D("-10.50")),
    ]
    assert lines[1].concept.startswith("Transacción con tarjeta: TIENDA")


@pytest.fixture
def h(client, make_user, monkeypatch):
    monkeypatch.setattr(px, "ecb_eur_per_usd", lambda client: lambda d: D("0.8"))
    monkeypatch.setattr(pf, "fund_name_ft", lambda client, isin: f"Fondo de prueba {isin[:2]}")
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def _send(client, h, url, content, name, replace=False):
    return client.post(url, headers=h, files={"file": (name, content, "text/csv")},
                       data={"replace_initial": "true" if replace else "false"})  # fmt: skip


def test_import_replaces_initial_position_and_undo_restores_it(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    a = client.post("/api/inv/assets", headers=h, json={
        "name": "Fondo FR", "type": "fondo", "isin": "FR0000000002",
        "asset_class_id": cls["Fondos"]}).json()  # fmt: skip
    client.post("/api/inv/transactions", headers=h, json={
        "asset_id": a["id"], "kind": "posicion_inicial", "trade_date": "2026-10-01",
        "units": "10.4", "avg_cost": "20"})  # fmt: skip

    r = _send(client, h, "/api/inv/imports/preview", MYINVESTOR, "mi.csv", replace=True)
    assert r.status_code == 200, r.text
    pv = r.json()
    assert pv["platform"] == "MyInvestor" and pv["counts"] == {"new": 5}
    assert pv["create_assets"] == [{"key": "IE0000000001", "name": "Fondo de prueba IE"}]
    pos = {x["key"]: x for x in pv["positions"]}
    assert pos["FR0000000002"]["units_now"] == "10.4"
    assert pos["FR0000000002"]["units_after"] == "10.4"  # 9,9 traspasadas + 0,5
    assert pos["FR0000000002"]["replaced_initial"] is True
    assert pos["IE0000000001"]["units_after"] == "0"
    # El traspaso hereda el coste (100 + 100) del fondo de origen: PMP (200 + 10) / 10,4
    assert pos["FR0000000002"]["avg_cost_after"].startswith("20.19")

    r = _send(client, h, "/api/inv/imports/commit", MYINVESTOR, "mi.csv", replace=True)
    assert r.status_code == 200, r.text
    batch = r.json()["id"]
    d = client.get(f"/api/inv/assets/{a['id']}", headers=h).json()
    assert d["position"]["units"] == "10.4"
    assert [lot["acquired"] for lot in d["lots"]] == ["2024-03-14", "2024-10-18", "2026-05-20"]
    assert all(t["kind"] != "posicion_inicial" for t in d["transactions"])
    # Reimportar: todo duplicado
    again = _send(client, h, "/api/inv/imports/preview", MYINVESTOR, "mi.csv").json()
    assert again["counts"] == {"duplicate": 5}

    # Deshacer: vuelve la posición inicial y desaparece el fondo creado
    assert client.post(f"/api/imports/{batch}/undo", headers=h).status_code == 200
    d = client.get(f"/api/inv/assets/{a['id']}", headers=h).json()
    assert d["position"]["units"] == "10.4"
    assert [t["kind"] for t in d["transactions"]] == ["posicion_inicial"]
    names = [x["name"] for x in client.get("/api/inv/assets", headers=h).json()]
    assert "Fondo de prueba IE" not in names


def test_neverless_import_creates_bitcoin(client, h):
    r = _send(client, h, "/api/inv/imports/commit", NEVERLESS, "nv.csv")
    assert r.status_code == 200, r.text
    assets = client.get("/api/inv/assets", headers=h).json()
    btc = next(a for a in assets if a["ticker"] == "BTC")
    assert btc["coingecko_id"] == "bitcoin" and btc["price_provider"] == "coingecko"
    d = client.get(f"/api/inv/assets/{btc['id']}", headers=h).json()
    assert d["position"]["units"] == "0.002001"
    assert {t["kind"] for t in d["transactions"]} == {"compra", "recompensa"}


def test_bank_lines_before_opening_are_skipped(client, h):
    body = {"bank": "Banco", "current_balance": "500.00", "payday_day": 27}
    assert client.post("/api/gastos/setup", json=body, headers=h).status_code == 201
    csv = b"Fecha;Concepto;Importe\n01/01/2020;Antiguo;-5,00\n"
    r = client.post("/api/imports/bank/preview", headers=h,
                    files={"file": ("b.csv", csv, "text/csv")})  # fmt: skip
    assert r.status_code == 200, r.text
    assert r.json()["counts"] == {"before_opening": 1}


def test_import_completes_pending_order_instead_of_duplicating(client, h):
    cls = {c["name"]: c["id"] for c in client.get("/api/inv/classes", headers=h).json()}
    a = client.post("/api/inv/assets", headers=h, json={
        "name": "Fondo FR", "type": "fondo", "isin": "FR0000000002",
        "asset_class_id": cls["Fondos"]}).json()  # fmt: skip
    # Orden generada en Faro el 19/05 por 10 €, aún sin VL
    r = client.post("/api/inv/contribution/orders", headers=h, json={
        "orders": [{"asset_id": a["id"], "amount": "10"}], "trade_date": "2026-05-19"})  # fmt: skip
    assert r.status_code == 201, r.text
    pv = _send(client, h, "/api/inv/imports/preview", MYINVESTOR, "mi.csv").json()
    assert pv["counts"]["complete_pending"] == 1
    b = _send(client, h, "/api/inv/imports/commit", MYINVESTOR, "mi.csv").json()
    txs = client.get(f"/api/inv/assets/{a['id']}", headers=h).json()["transactions"]
    done = [t for t in txs if t["trade_date"] == "2026-05-20"]
    assert len(done) == 1 and done[0]["status"] == "liquidada" and done[0]["units"] == "0.5"
    assert client.get("/api/inv/transactions?pending_only=true", headers=h).json() == []
    # Deshacer: vuelve a estar pendiente, con su fecha e importe originales
    client.post(f"/api/imports/{b['id']}/undo", headers=h)
    pend = client.get("/api/inv/transactions?pending_only=true", headers=h).json()
    assert [(t["trade_date"], t["amount_eur"]) for t in pend] == [("2026-05-19", "10.00")]

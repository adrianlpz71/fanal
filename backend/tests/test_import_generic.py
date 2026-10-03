"""Importador genérico (columnas elegidas por el usuario) de operaciones y de extractos, con
formatos guardados. Ficheros sintéticos: un broker y un banco que Faro no conoce."""

import json
from datetime import date
from decimal import Decimal as D

import pytest

from app.importers import generic_broker as gb
from app.importers import platforms as pf
from app.importers.tabular import read_table
from app.services import prices as px
from tests.conftest import auth_header, enroll

# Un broker cualquiera: columnas en otro orden, coma decimal, tipo de operación en texto
BROKER = """Informe de operaciones
Fecha;Producto;ISIN;Operación;Títulos;Importe (EUR);Comisión;Id
03/02/2026;Fondo Global A;IE00AAAAAAA1;Suscripción;12,5;150,00;0;OP-1
03/03/2026;Fondo Global A;IE00AAAAAAA1;Suscripción;11,9;150,00;0;OP-2
10/03/2026;Fondo Bonos B;LU00BBBBBBB2;Compra;4,25;100,00;0,50;OP-3
20/03/2026;Fondo Global A;IE00AAAAAAA1;Reembolso;5;64,10;0;OP-4
21/03/2026;Fondo Global A;IE00AAAAAAA1;Dividendo;0;1,20;0;OP-5
""".encode()
BROKER_MAP = {
    "platform": "Broker X",
    "header_row": 1,
    "date": 0,
    "name": 1,
    "key": 2,
    "kind": 3,
    "units": 4,
    "amount": 5,
    "fee": 6,
    "ref": 7,
    "key_type": "isin",
    "asset_type": "fondo",
    "decimal": "comma",
}

# Un banco desconocido: cabeceras que la detección automática no reconoce
BANK = """Mi Banco - movimientos
Día;Texto;Euros;Resto
05/10/2026;Supermercado;-45,20;954,80
06/10/2026;Transferencia recibida;100,00;1054,80
""".encode()
BANK_MAP = {"header_row": 1, "date": 0, "concept": [1], "amount": 2, "balance": 3}


def test_generic_parse_kinds_decimals_and_warnings():
    rows = read_table(BROKER, "x.csv")
    ops, warnings = gb.parse(rows, gb.mapping_from_dict(BROKER_MAP))
    assert [(o.kind, o.key, o.units, o.amount_eur) for o in ops] == [
        ("compra", "IE00AAAAAAA1", D("12.5"), D("150.00")),
        ("compra", "IE00AAAAAAA1", D("11.9"), D("150.00")),
        ("compra", "LU00BBBBBBB2", D("4.25"), D("100.00")),
        ("venta", "IE00AAAAAAA1", D("5"), D("64.10")),
    ]
    assert ops[2].fee == D("0.50") and ops[0].on == date(2026, 2, 3)
    assert ops[0].ref == "Broker X|OP-1"
    assert any("0 participaciones" in w for w in warnings)  # el dividendo sin títulos se avisa


def test_generic_without_kind_column_uses_sign_and_hashes_duplicates():
    csv = (
        b"date,ticker,qty,eur\n"
        b"2026-01-05,AAPL,2,300\n2026-01-05,AAPL,2,300\n2026-02-01,AAPL,-1,160\n"
    )
    m = gb.mapping_from_dict(
        {
            "platform": "US Broker",
            "date": 0,
            "key": 1,
            "units": 2,
            "amount": 3,
            "key_type": "ticker",
            "asset_type": "accion",
            "decimal": "point",
        }
    )
    ops, _ = gb.parse(read_table(csv, "x.csv"), m)
    assert [o.kind for o in ops] == ["compra", "compra", "venta"]
    assert ops[0].ref != ops[1].ref  # dos compras idénticas el mismo día no se funden


@pytest.mark.parametrize(
    "bad",
    [
        {**BROKER_MAP, "platform": " "},
        {**BROKER_MAP, "units": 0},  # misma columna que la fecha
        {**BROKER_MAP, "key_type": "nombre"},
        {"platform": "X", "date": 0},
    ],
)
def test_generic_mapping_validation(bad):
    with pytest.raises(gb.MappingError):
        gb.mapping_from_dict(bad)


@pytest.fixture
def h(client, make_user, monkeypatch):
    monkeypatch.setattr(px, "ecb_eur_per_usd", lambda client: lambda d: D("0.8"))
    monkeypatch.setattr(pf, "fund_name_ft", lambda client, isin: None)
    make_user("ana@example.com")
    return auth_header(enroll(client, "ana@example.com"))


def _post(client, h, url, content, name, **data):
    return client.post(url, headers=h, files={"file": (name, content, "text/csv")}, data=data)


def test_broker_generic_import_profile_and_undo(client, h):
    r = _post(
        client, h, "/api/inv/imports/preview", BROKER, "broker.csv", mapping=json.dumps(BROKER_MAP)
    )
    assert r.status_code == 200, r.text
    pv = r.json()
    assert pv["source"] == "generic" and pv["platform"] == "Broker X"
    assert pv["counts"] == {"new": 4}
    # Los activos nuevos se llaman como en el fichero
    assert {a["name"] for a in pv["create_assets"]} == {"Fondo Global A", "Fondo Bonos B"}
    pos = {x["key"]: x for x in pv["positions"]}
    assert pos["IE00AAAAAAA1"]["units_after"] == "19.4"  # 12,5 + 11,9 − 5
    r = _post(
        client,
        h,
        "/api/inv/imports/commit",
        BROKER,
        "broker.csv",
        mapping=json.dumps(BROKER_MAP),
        save_profile_as="Broker X",
    )
    assert r.status_code == 200, r.text
    batch = r.json()["id"]
    assets = {a["name"]: a for a in client.get("/api/inv/assets", headers=h).json()}
    assert assets["Fondo Global A"]["type"] == "fondo" and assets["Fondo Global A"]["isin"]
    assert assets["Fondo Global A"]["price_provider"] == "ft"
    # El formato queda guardado y se reutiliza: reimportar con él no duplica nada
    profs = client.get("/api/imports/profiles", params={"kind": "broker"}, headers=h).json()
    assert [p["name"] for p in profs] == ["Broker X"]
    assert client.get("/api/imports/profiles", headers=h).json() == []  # los de banco, aparte
    again = _post(
        client, h, "/api/inv/imports/preview", BROKER, "broker.csv", profile_id=profs[0]["id"]
    ).json()
    assert again["counts"] == {"duplicate": 4}
    # Deshacer quita las operaciones y los activos creados
    assert client.post(f"/api/imports/{batch}/undo", headers=h).status_code == 200
    assert client.get("/api/inv/assets", headers=h).json() == []
    assert client.delete(f"/api/imports/profiles/{profs[0]['id']}", headers=h).status_code == 204


def test_broker_generic_stocks_by_ticker(client, h):
    csv = b"date,ticker,qty,eur\n2026-01-05,AAPL,2,300\n"
    m = {
        "platform": "US Broker",
        "date": 0,
        "key": 1,
        "units": 2,
        "amount": 3,
        "key_type": "ticker",
        "asset_type": "accion",
        "decimal": "point",
    }
    r = _post(client, h, "/api/inv/imports/commit", csv, "us.csv", mapping=json.dumps(m))
    assert r.status_code == 200, r.text
    (a,) = client.get("/api/inv/assets", headers=h).json()
    cls = {c["id"]: c["name"] for c in client.get("/api/inv/classes", headers=h).json()}
    assert (a["name"], a["type"], a["ticker"], a["price_provider"]) == (
        "AAPL",
        "accion",
        "AAPL",
        "manual",
    )
    assert cls[a["asset_class_id"]] == "Acciones"


def test_broker_generic_bad_mapping_is_a_clear_error(client, h):
    r = _post(
        client,
        h,
        "/api/inv/imports/preview",
        BROKER,
        "broker.csv",
        mapping=json.dumps({"platform": "X", "date": 0}),
    )
    assert r.status_code == 422 and "columnas" in r.json()["detail"]


def test_bank_inspect_manual_mapping_and_profile(client, h):
    from tests.test_api_gastos import setup_gastos

    setup_gastos(client, h)
    # Formato desconocido: la detección falla, pero se ven las filas para elegir columnas
    ins = _post(client, h, "/api/imports/inspect", BANK, "banco.csv").json()
    assert ins["suggested"] is None and ins["message"]
    assert ins["rows"][1] == ["Día", "Texto", "Euros", "Resto"]
    assert _post(client, h, "/api/imports/bank/preview", BANK, "banco.csv").status_code == 422
    pv = _post(
        client, h, "/api/imports/bank/preview", BANK, "banco.csv", mapping=json.dumps(BANK_MAP)
    ).json()
    assert pv["counts"] == {"new": 2}
    r = _post(
        client,
        h,
        "/api/imports/bank/commit",
        BANK,
        "banco.csv",
        mapping=json.dumps(BANK_MAP),
        save_profile_as="Mi Banco",
    )
    assert r.status_code == 200, r.text
    (prof,) = client.get("/api/imports/profiles", headers=h).json()
    assert prof["name"] == "Mi Banco" and prof["mapping"]["amount"] == 2
    dup = _post(
        client, h, "/api/imports/bank/preview", BANK, "banco.csv", profile_id=prof["id"]
    ).json()
    assert dup["counts"] == {"duplicate": 2}
    # Un formato conocido sí trae sugerencia
    known = "Fecha;Concepto;Importe\n05/10/2026;Café;-2,00\n".encode()
    assert (
        _post(client, h, "/api/imports/inspect", known, "k.csv").json()["suggested"]["amount"] == 2
    )


def test_broker_columns_are_suggested_from_headers():
    s = gb.suggest(read_table(BROKER, "x.csv"))
    assert s == {
        "header_row": 1,
        "date": 0,
        "key": 2,
        "units": 4,
        "amount": 5,
        "kind": 3,
        "fee": 6,
        "name": 1,
        "ref": 7,
        "key_type": "isin",
    }

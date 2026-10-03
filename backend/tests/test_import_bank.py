"""Importación de extractos bancarios con ficheros sintéticos (formatos españoles típicos).
Cuando haya un extracto real de un banco concreto, se añade su versión anonimizada como fixture."""

import io
from datetime import date, timedelta

import openpyxl
import pytest
from sqlalchemy import update

from app.db import SessionLocal
from app.importers.bank import detect_mapping, parse_lines
from app.importers.tabular import TableError, read_table
from app.models import Account
from tests.conftest import auth_header, enroll
from tests.test_api_gastos import add, current, setup_gastos

TODAY = date.today()
D = lambda n: (TODAY - timedelta(days=n)).strftime("%d/%m/%Y")  # noqa: E731

CSV = (
    "Banco Ejemplo;;;\n"
    "Movimientos de la cuenta;;;\n"
    ";;;\n"
    "Fecha;Fecha valor;Concepto;Importe;Saldo\n"
    f"{D(5)};{D(5)};COMPRA BURGER BAR;-12,50;987,50\n"
    f"{D(4)};{D(4)};BIZUM DE LUIS;20,00;1.007,50\n"
    f"{D(3)};{D(3)};FIBRA HOGAR;-9,00;998,50\n"
    f"{D(2)};{D(2)};COMPRA BURGER BAR;-12,50;986,00\n"
    f"{D(2)};{D(2)};COMPRA BURGER BAR;-12,50;973,50\n"
)


def upload(client, h, content: bytes, name="extracto.csv", path="preview", **form):
    return client.post(f"/api/imports/bank/{path}", headers=h,
                       files={"file": (name, content)}, data=form)  # fmt: skip


@pytest.fixture
def h(client, make_user):
    make_user("ana@example.com")
    hh = auth_header(enroll(client, "ana@example.com"))
    setup_gastos(client, hh, balance="1000.00")
    _open_since(60)
    return hh


def _open_since(days: int) -> None:
    """La cuenta existe desde hace tiempo (el extracto trae movimientos posteriores a su saldo
    inicial); si se abriera hoy, lo anterior ya estaría dentro del saldo y no se importaría."""
    with SessionLocal() as db:
        db.execute(update(Account).values(opening_date=TODAY - timedelta(days=days)))
        db.commit()


def test_read_and_detect_spanish_csv_latin1():
    rows = read_table(CSV.encode("cp1252"), "x.csv")
    m = detect_mapping(rows)
    assert m.header_row == 3 and m.amount == 3 and m.balance == 4 and m.value_date == 1
    lines = parse_lines(rows, m).lines
    assert [str(x.amount) for x in lines] == ["-12.50", "20.00", "-9.00", "-12.50", "-12.50"]
    assert str(lines[1].balance) == "1007.50"  # "1.007,50"


def test_xlsx_with_debit_credit_columns():
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.append(["Extracto"])
    ws.append(["F. Operación", "Descripción", "Observaciones", "Cargo", "Abono"])
    ws.append([TODAY, "RECIBO GIMNASIO", "mensual", 30.0, None])
    ws.append([TODAY, "TRANSFERENCIA RECIBIDA", None, None, 1845.0])
    buf = io.BytesIO()
    wb.save(buf)
    rows = read_table(buf.getvalue(), "x.xlsx")
    m = detect_mapping(rows)
    lines = parse_lines(rows, m).lines
    assert [str(x.amount) for x in lines] == ["-30.00", "1845.00"]
    assert lines[0].notes == "mensual"


def test_unknown_format_fails_clearly():
    with pytest.raises(TableError):
        detect_mapping(read_table(b"a;b;c\n1;2;3\n", "x.csv"))


def test_preview_commit_match_dedupe_and_undo(client, h):
    planned = add(client, h, "Fibra", "-9.00", status="planned", due_date=TODAY.isoformat())
    manual = add(client, h, "Burger", "-12.50", date=(TODAY - timedelta(days=5)).isoformat())
    pv = upload(client, h, CSV.encode("utf-8"))
    assert pv.status_code == 200, pv.text
    p = pv.json()
    assert p["counts"] == {"match_posted": 1, "new": 3, "match_planned": 1}
    out = {(ln["concept"], ln["row"]): ln["outcome"] for ln in p["lines"]}
    assert out[("FIBRA HOGAR", 7)] == "match_planned"
    assert out[("COMPRA BURGER BAR", 5)] == "match_posted"  # el que apunté a mano: no se duplica
    assert p["file_balance"] == "973.50"
    # La vista previa no escribe nada
    assert len(current(client, h)["movements"]) == 2

    c = upload(client, h, CSV.encode("utf-8"), path="commit", save_profile_as="Banco Ejemplo")
    assert c.status_code == 200, c.text
    batch = c.json()
    mv = {m["id"]: m for m in current(client, h)["movements"]}
    assert mv[planned["id"]]["status"] == "posted"  # emparejado → cargado con la fecha real
    assert mv[manual["id"]]["amount"] == "-12.50"
    assert len(mv) == 5  # 2 previos + 3 nuevos (Bizum y las dos hamburguesas del mismo día)
    bizum = next(m for m in mv.values() if m["concept"] == "BIZUM DE LUIS")
    assert bizum["kind"] == "ingreso"
    assert client.get("/api/accounts", headers=h).json()[0]["balance"] == "973.50"  # = extracto

    # Reimportar el mismo fichero (o uno solapado) no duplica
    again = upload(client, h, CSV.encode("utf-8")).json()
    assert again["counts"] == {"duplicate": 5}
    extra = CSV + f"{D(1)};{D(1)};NETFLIX;-9,99;963,51\n"
    assert upload(client, h, extra.encode("utf-8")).json()["counts"] == {"duplicate": 5, "new": 1}

    # Perfil guardado y reutilizable
    prof = client.get("/api/imports/profiles", headers=h).json()
    assert prof[0]["name"] == "Banco Ejemplo"
    assert (
        upload(client, h, CSV.encode(), profile_id=prof[0]["id"]).json()["counts"]["duplicate"] == 5
    )

    # Deshacer: vuelve todo a como estaba
    u = client.post(f"/api/imports/{batch['id']}/undo", headers=h)
    assert u.status_code == 200 and u.json()["status"] == "undone"
    mv = {m["id"]: m for m in current(client, h)["movements"]}
    assert len(mv) == 2 and mv[planned["id"]]["status"] == "planned"
    assert client.post(f"/api/imports/{batch['id']}/undo", headers=h).status_code == 409


def test_learned_rule_categorizes_bank_lines(client, h):
    cats = {c["name"]: c["id"] for c in client.get("/api/categories", headers=h).json()}
    m = add(client, h, "BIZUM DE LUIS", "20.00", kind="ingreso")
    client.patch(f"/api/movements/{m['id']}", json={"category_id": cats["Reembolsos"]}, headers=h)
    p = upload(client, h, CSV.encode()).json()
    bizum = next(ln for ln in p["lines"] if ln["concept"] == "BIZUM DE LUIS")
    # (el movimiento manual no tiene fecha de banco ±3 días → se propone como nuevo con su regla)
    assert bizum["category_id"] == cats["Reembolsos"] or bizum["outcome"] == "match_posted"


def test_bad_file_is_rejected(client, h):
    r = upload(client, h, b"no;es;un;extracto\n1;2;3;4\n")
    assert r.status_code == 422


def test_import_isolation(client, make_user, h):
    make_user("bea@example.com")
    hb = auth_header(enroll(client, "bea@example.com"))
    setup_gastos(client, hb)
    batch = upload(client, h, CSV.encode(), path="commit").json()
    acc_a = client.get("/api/accounts", headers=h).json()[0]["id"]
    assert client.post(f"/api/imports/{batch['id']}/undo", headers=hb).status_code == 404
    assert upload(client, hb, CSV.encode(), account_id=acc_a).status_code == 404
    assert client.get("/api/imports", headers=hb).json() == []


def test_mappings_never_carry_nulls(client, h):
    """El cliente Dart tipa los mapeos como Map<String, Object>: un null rompía la vista previa
    entera en la app ("Error inesperado")."""
    p = upload(client, h, CSV.encode("utf-8")).json()
    assert p["mapping"] and None not in p["mapping"].values()
    ins = client.post(
        "/api/imports/inspect", headers=h, files={"file": ("extracto.csv", CSV.encode("utf-8"))}
    ).json()
    assert ins["suggested"] and None not in ins["suggested"].values()
    upload(client, h, CSV.encode("utf-8"), path="commit", save_profile_as="Banco Ejemplo")
    profiles = client.get("/api/imports/profiles", headers=h, params={"kind": "bank"}).json()
    assert profiles and all(None not in pr["mapping"].values() for pr in profiles)

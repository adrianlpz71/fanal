"""Comandos de administración (no hay registro público de usuarios).

python -m app.cli create-user --email x@y.z [--name "Nombre"]   # pide la contraseña por stdin
python -m app.cli reset-2fa --email x@y.z      # obliga a dar de alta la 2FA otra vez
python -m app.cli networth-audit --email x@y.z # SOLO LECTURA: serie de patrimonio vs saldos reales
"""

import argparse
import getpass
import sys

from sqlalchemy import delete, func, select

from app.db import SessionLocal
from app.models import AuditLog, RecoveryCode, RefreshToken, User
from app.security.passwords import hash_password, validate_password_strength


def _read_password(from_stdin: bool) -> str:
    if from_stdin:
        return sys.stdin.readline().rstrip("\n")
    p1 = getpass.getpass("Contraseña: ")
    p2 = getpass.getpass("Repite la contraseña: ")
    if p1 != p2:
        sys.exit("Las contraseñas no coinciden")
    return p1


def create_user(email: str, name: str, from_stdin: bool) -> None:
    email = email.lower().strip()
    password = _read_password(from_stdin)
    if problems := validate_password_strength(password):
        sys.exit("Contraseña débil: " + "; ".join(problems))
    with SessionLocal() as db:
        if db.scalar(select(User).where(User.email == email)):
            sys.exit(f"Ya existe {email}")
        u = User(email=email, display_name=name, password_hash=hash_password(password))
        db.add(u)
        db.flush()
        db.add(AuditLog(user_id=u.id, entity="user", entity_id=str(u.id), action="created"))
        db.commit()
        print(f"Usuario creado: {email}. Al iniciar sesión se pedirá dar de alta la 2FA.")


def reset_2fa(email: str) -> None:
    with SessionLocal() as db:
        u = db.scalar(select(User).where(User.email == email.lower().strip()))
        if not u:
            sys.exit("No existe")
        u.totp_enabled = False
        u.totp_secret_enc = None
        db.execute(delete(RecoveryCode).where(RecoveryCode.user_id == u.id))
        db.execute(delete(RefreshToken).where(RefreshToken.user_id == u.id))
        db.add(AuditLog(user_id=u.id, entity="auth", action="2fa.reset_cli"))
        db.commit()
        print("2FA reseteada y sesiones cerradas.")


def _eur(v) -> str:
    return f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")


def networth_audit(email: str) -> None:
    """Imprime la serie de patrimonio reconstruida (D9) frente a lo que se sabe de verdad: el
    arrastre real de cada ciclo cerrado y la tarjeta de hoy. Transacción de SOLO LECTURA."""
    from collections import Counter
    from datetime import date, timedelta
    from decimal import Decimal

    from sqlalchemy import text

    from app.models import Account, Movement, PayCycle
    from app.services import analytics as an
    from app.services import networth as nw

    with SessionLocal() as db:
        db.execute(text("SET TRANSACTION READ ONLY"))
        u = db.scalar(select(User).where(User.email == email.lower().strip()))
        if not u:
            sys.exit("No existe")
        accounts = list(db.scalars(select(Account).where(Account.user_id == u.id)))
        cycles = sorted(
            db.scalars(select(PayCycle).where(PayCycle.user_id == u.id)),
            key=lambda c: (c.account_id, c.start_date),
        )
        closes = {
            c.end_date - timedelta(days=1) for c in cycles if c.status == "closed" and c.end_date
        }
        h = nw.history(db, u.id, extra_days=closes)
        at = {p.on: p for p in h.points}
        print(f"# Auditoría de la serie de patrimonio · {date.today()}")
        print(f"Serie desde {h.start} · un punto por ciclo hasta {h.per_cycle_until or '-'}")

        print("\n## Cuentas hoy")
        last = h.points[-1] if h.points else None
        for a in accounts:
            bal = last.components.get(f"c:{a.id}") if last else None
            flag = " (archivada)" if a.archived else ""
            hoy = _eur(bal) if bal is not None else "-"
            print(
                f"- {a.name}{flag} · {a.kind} · alta {a.opening_date} · "
                f"inicial {_eur(a.opening_balance)} · hoy {hoy}"
            )

        print("\n## Traspasos de una pata")
        count: Counter[str] = Counter()
        sums: dict[str, Decimal] = {}
        for t in h.own_transfers:
            count[t.to.name] += 1
            sums[t.to.name] = sums.get(t.to.name, Decimal(0)) - t.movement.amount
        for name, n in count.items():
            print(f"- Entre tus cuentas (no cambian el total) -> {name}: {n} · {_eur(sums[name])}")
        other: dict[str, list[Decimal]] = {}
        for m, _ in h.other_one_leg:
            other.setdefault(m.concept.strip().lower(), []).append(m.amount)
        for concept, amounts in sorted(other.items()):
            print(f"- Salen de tus cuentas «{concept}»: {len(amounts)} · {_eur(sum(amounts))}")
        if not h.own_transfers and not other:
            print("- Ninguno")

        print("\n## Ciclos cerrados: saldo reconstruido al cierre vs arrastre real")
        print("| ciclo | cierre | reconstruido | arrastre real | diferencia |")
        print("|---|---|---|---|---|")
        for i, c in enumerate(cycles):
            if c.status != "closed" or not c.end_date:
                continue
            nxt = next((x for x in cycles[i + 1 :] if x.account_id == c.account_id), None)
            day = c.end_date - timedelta(days=1)
            rebuilt = at[day].components.get(f"c:{c.account_id}") if day in at else None
            real = nxt.carried_real if nxt else None
            diff = rebuilt - real if rebuilt is not None and real is not None else None
            cells = [_eur(x) if x is not None else "-" for x in (rebuilt, real, diff)]
            print(f"| {c.label} | {day} | " + " | ".join(cells) + " |")

        print("\n## Serie")
        names = {c.key: c.label for c in h.components}
        keys = [c.key for c in h.components]
        head = [names[k] for k in keys] + ["cuentas", "inversiones", "deudas", "fracc.", "neto"]
        print("| fecha | " + " | ".join(head) + " |")
        print("|---" * (len(head) + 1) + "|")
        for p in h.points:
            if p.on in closes and h.per_cycle_until and p.on > h.per_cycle_until:
                continue  # cierres añadidos solo para la tabla de arriba
            cells = [_eur(p.components.get(k, 0)) for k in keys]
            cells += [_eur(x) for x in (p.accounts, p.investments, p.debts, p.installments, p.net)]
            print(f"| {p.on} | " + " | ".join(cells) + " |")

        print("\n## Comprobaciones")
        card = an.networth(db, u.id)
        if last is not None:
            card_acc = sum((b for _, b in card.accounts), Decimal(0))
            print(f"- Hoy, cuentas: serie {_eur(last.accounts)} · tarjeta {_eur(card_acc)}")
            print(f"- Hoy, neto: serie {_eur(last.net)} · tarjeta {_eur(card.total)}")
        neg = sorted(
            {
                (names.get(k, k), p.on)
                for p in h.points
                for k, v in p.components.items()
                if k.startswith("c:") and v < 0
            }
        )
        first = f" (primero: {neg[0][0]} el {neg[0][1]})" if neg else ""
        print(f"- Saldos negativos en la reconstrucción: {len(neg)}{first}")
        early = db.scalar(
            select(func.count())
            .select_from(Movement)
            .join(Account, Account.id == Movement.account_id)
            .where(
                Movement.user_id == u.id,
                Movement.status == "posted",
                Movement.date < Account.opening_date,
            )
        )
        print(f"- Movimientos con fecha anterior al alta de su cuenta: {early}")
        db.rollback()


def main() -> None:
    p = argparse.ArgumentParser(prog="app.cli")
    sub = p.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("create-user")
    c.add_argument("--email", required=True)
    c.add_argument("--name", default="")
    c.add_argument("--password-stdin", action="store_true")
    r = sub.add_parser("reset-2fa")
    r.add_argument("--email", required=True)
    na = sub.add_parser("networth-audit")
    na.add_argument("--email", required=True)
    a = p.parse_args()
    if a.cmd == "create-user":
        create_user(a.email, a.name, a.password_stdin)
    elif a.cmd == "reset-2fa":
        reset_2fa(a.email)
    elif a.cmd == "networth-audit":
        networth_audit(a.email)


if __name__ == "__main__":
    main()

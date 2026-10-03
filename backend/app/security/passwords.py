from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError, VerifyMismatchError

# Parámetros argon2id por defecto de argon2-cffi (RFC 9106, perfil de baja memoria): 64 MiB, t=3.
_ph = PasswordHasher()

# Hash señuelo para igualar el tiempo de respuesta cuando el email no existe.
_DUMMY_HASH = _ph.hash("faro-dummy-password-for-timing")


def hash_password(password: str) -> str:
    return _ph.hash(password)


def verify_password(password_hash: str | None, password: str) -> bool:
    try:
        return _ph.verify(password_hash or _DUMMY_HASH, password) and password_hash is not None
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def needs_rehash(password_hash: str) -> bool:
    return _ph.check_needs_rehash(password_hash)


def validate_password_strength(password: str) -> list[str]:
    problems = []
    if len(password) < 12:
        problems.append("Mínimo 12 caracteres")
    if password.lower() == password or password.upper() == password:
        problems.append("Mezcla mayúsculas y minúsculas")
    if not any(c.isdigit() for c in password):
        problems.append("Incluye al menos un número")
    return problems

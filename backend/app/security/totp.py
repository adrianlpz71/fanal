import secrets

import pyotp
from cryptography.fernet import Fernet

from app.config import get_settings
from app.security.passwords import hash_password, verify_password


def _fernet() -> Fernet:
    return Fernet(get_settings().totp_encryption_key.encode())


def new_secret() -> str:
    return pyotp.random_base32()


def encrypt_secret(secret: str) -> str:
    return _fernet().encrypt(secret.encode()).decode()


def decrypt_secret(token: str) -> str:
    return _fernet().decrypt(token.encode()).decode()


def provisioning_uri(secret: str, email: str) -> str:
    return pyotp.TOTP(secret).provisioning_uri(name=email, issuer_name=get_settings().totp_issuer)


def verify_code(secret: str, code: str) -> bool:
    code = code.strip().replace(" ", "")
    if not code.isdigit() or len(code) != 6:
        return False
    # valid_window=1 tolera ±30 s de desfase de reloj
    return pyotp.TOTP(secret).verify(code, valid_window=1)


def new_recovery_codes(n: int = 10) -> list[str]:
    alphabet = "abcdefghjkmnpqrstuvwxyz23456789"
    return [
        "-".join("".join(secrets.choice(alphabet) for _ in range(4)) for _ in range(2))
        for _ in range(n)
    ]


def hash_recovery_code(code: str) -> str:
    return hash_password(normalize_recovery_code(code))


def verify_recovery_code(code_hash: str, code: str) -> bool:
    return verify_password(code_hash, normalize_recovery_code(code))


def normalize_recovery_code(code: str) -> str:
    c = code.strip().lower().replace(" ", "").replace("-", "")
    return f"{c[:4]}-{c[4:]}"


def looks_like_recovery_code(code: str) -> bool:
    c = code.strip().replace("-", "").replace(" ", "")
    return len(c) == 8 and not c.isdigit()

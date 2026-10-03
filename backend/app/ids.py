"""UUIDv7 (RFC 9562): 48 bits de timestamp en ms + aleatorio. Ordenables por tiempo, lo que
mantiene los índices compactos, y generables en el cliente (cola offline idempotente)."""

import os
import time
import uuid


def uuid7() -> uuid.UUID:
    ts_ms = time.time_ns() // 1_000_000
    rand = int.from_bytes(os.urandom(10), "big")  # 80 bits
    rand_a = rand >> 68  # 12 bits
    rand_b = rand & ((1 << 62) - 1)  # 62 bits
    value = (ts_ms & ((1 << 48) - 1)) << 80
    value |= 0x7 << 76
    value |= rand_a << 64
    value |= 0b10 << 62
    value |= rand_b
    return uuid.UUID(int=value)

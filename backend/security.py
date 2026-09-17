"""Password hashing and JWT helpers (no native build dependencies)."""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
import time
from typing import Any

from .config import get_settings

_PBKDF2_ITERATIONS = 180_000
_PBKDF2_ALGO = "sha256"


def _b64url_encode(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def _b64url_decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def hash_password(password: str) -> str:
    salt = secrets.token_hex(16)
    derived = hashlib.pbkdf2_hmac(
        _PBKDF2_ALGO, password.encode("utf-8"), salt.encode("ascii"), _PBKDF2_ITERATIONS
    ).hex()
    return f"pbkdf2_{_PBKDF2_ALGO}${_PBKDF2_ITERATIONS}${salt}${derived}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        algorithm, iterations, salt, expected = encoded.split("$", 3)
        derived = hashlib.pbkdf2_hmac(
            algorithm.split("_", 1)[1],
            password.encode("utf-8"),
            salt.encode("ascii"),
            int(iterations),
        ).hex()
    except (ValueError, IndexError):
        return False
    return hmac.compare_digest(derived, expected)


def create_access_token(subject: str, extra: dict[str, Any] | None = None) -> str:
    settings = get_settings()
    now = int(time.time())
    payload: dict[str, Any] = {
        "sub": subject,
        "iat": now,
        "exp": now + settings.jwt_expires_hours * 3600,
    }
    if extra:
        payload.update(extra)

    header_segment = _b64url_encode(
        json.dumps({"alg": settings.jwt_algorithm, "typ": "JWT"}, separators=(",", ":")).encode()
    )
    payload_segment = _b64url_encode(
        json.dumps(payload, separators=(",", ":"), default=str).encode()
    )
    signing_input = f"{header_segment}.{payload_segment}".encode("ascii")
    signature = hmac.new(
        settings.jwt_secret.encode("utf-8"), signing_input, hashlib.sha256
    ).digest()
    return f"{header_segment}.{payload_segment}.{_b64url_encode(signature)}"


def decode_access_token(token: str) -> dict[str, Any] | None:
    settings = get_settings()
    try:
        header_segment, payload_segment, signature_segment = token.split(".")
    except ValueError:
        return None

    signing_input = f"{header_segment}.{payload_segment}".encode("ascii")
    expected = hmac.new(
        settings.jwt_secret.encode("utf-8"), signing_input, hashlib.sha256
    ).digest()
    try:
        provided = _b64url_decode(signature_segment)
    except (ValueError, TypeError):
        return None
    if not hmac.compare_digest(expected, provided):
        return None

    try:
        payload = json.loads(_b64url_decode(payload_segment).decode("utf-8"))
    except (ValueError, TypeError):
        return None
    if int(payload.get("exp", 0)) < int(time.time()):
        return None
    return payload

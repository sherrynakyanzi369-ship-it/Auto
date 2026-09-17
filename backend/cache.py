"""Redis cache layer.

Supports Upstash REST (recommended on Vercel), a standard Redis URL
(``REDIS_URL``) and an in-process fallback so local development and tests keep
working without any infrastructure.

The cache is also used as a *read fallback*: when PostgreSQL is unreachable the
API serves the most recently cached payload (``stale-while-revalidate`` style).
"""

from __future__ import annotations

import json
import logging
import time
import urllib.error
import urllib.request
from typing import Any

from .config import get_settings

logger = logging.getLogger("autoassist.cache")

_MEMORY: dict[str, tuple[float, str]] = {}
_REDIS_CLIENT: Any = None


def _memory_get(key: str) -> str | None:
    entry = _MEMORY.get(key)
    if entry is None:
        return None
    expires_at, value = entry
    if expires_at and expires_at < time.time():
        _MEMORY.pop(key, None)
        return None
    return value


def _memory_set(key: str, value: str, ttl: int) -> None:
    _MEMORY[key] = (time.time() + ttl if ttl > 0 else 0.0, value)


def _upstash(command: list[Any]) -> Any:
    settings = get_settings()
    body = json.dumps(command).encode("utf-8")
    request = urllib.request.Request(
        settings.upstash_rest_url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {settings.upstash_rest_token}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=2.5) as response:
        payload = json.loads(response.read().decode("utf-8") or "{}")
    return payload.get("result")


def _get_redis_client() -> Any:
    global _REDIS_CLIENT
    settings = get_settings()
    if not settings.redis_url:
        return None
    if _REDIS_CLIENT is None:
        try:
            import redis  # type: ignore

            _REDIS_CLIENT = redis.from_url(
                settings.redis_url,
                decode_responses=True,
                socket_connect_timeout=2,
                socket_timeout=2,
            )
        except Exception as exc:  # pragma: no cover - optional dependency
            logger.warning("redis client unavailable: %s", exc)
            _REDIS_CLIENT = False  # type: ignore[assignment]
    return _REDIS_CLIENT or None


def cache_get(key: str) -> str | None:
    settings = get_settings()
    if not settings.cache_enabled:
        return None

    if settings.upstash_rest_url and settings.upstash_rest_token:
        try:
            value = _upstash(["GET", key])
            if value is not None:
                return str(value)
        except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
            logger.warning("upstash GET failed: %s", exc)
        return _memory_get(key)

    client = _get_redis_client()
    if client is not None:
        try:
            value = client.get(key)
            if value is not None:
                return str(value)
        except Exception as exc:  # pragma: no cover
            logger.warning("redis GET failed: %s", exc)
        return _memory_get(key)

    return _memory_get(key)


def cache_set(key: str, value: str, ttl: int | None = None) -> None:
    settings = get_settings()
    if not settings.cache_enabled:
        return

    ttl = settings.cache_ttl if ttl is None else ttl

    if settings.upstash_rest_url and settings.upstash_rest_token:
        try:
            if ttl > 0:
                _upstash(["SET", key, value, "EX", ttl])
            else:
                _upstash(["SET", key, value])
        except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
            logger.warning("upstash SET failed: %s", exc)
        _memory_set(key, value, ttl)
        return

    client = _get_redis_client()
    if client is not None:
        try:
            if ttl > 0:
                client.set(key, value, ex=ttl)
            else:
                client.set(key, value)
        except Exception as exc:  # pragma: no cover
            logger.warning("redis SET failed: %s", exc)
        _memory_set(key, value, ttl)
        return

    _memory_set(key, value, ttl)


def cache_delete(*keys: str) -> None:
    if not keys:
        return
    for key in keys:
        _MEMORY.pop(key, None)

    settings = get_settings()
    if settings.upstash_rest_url and settings.upstash_rest_token:
        try:
            _upstash(["DEL", *keys])
        except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
            logger.warning("upstash DEL failed: %s", exc)
        return

    client = _get_redis_client()
    if client is not None:
        try:
            client.delete(*keys)
        except Exception as exc:  # pragma: no cover
            logger.warning("redis DEL failed: %s", exc)


def cache_get_json(key: str) -> Any | None:
    raw = cache_get(key)
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except (TypeError, ValueError):
        return None


def cache_set_json(key: str, value: Any, ttl: int | None = None) -> None:
    try:
        cache_set(key, json.dumps(value, default=str), ttl)
    except (TypeError, ValueError) as exc:
        logger.warning("cache serialization failed for %s: %s", key, exc)


def cache_health() -> bool:
    settings = get_settings()
    if not settings.cache_enabled:
        return False
    if settings.upstash_rest_url and settings.upstash_rest_token:
        try:
            _upstash(["PING"])
            return True
        except Exception:
            return False
    client = _get_redis_client()
    if client is not None:
        try:
            client.ping()
            return True
        except Exception:
            return False
    return bool(_MEMORY)

"""Environment-driven configuration for the AutoAssist API."""

from __future__ import annotations

import os
from functools import lru_cache


def _clean(value: str | None) -> str:
    return (value or "").strip()


def _normalize_database_url(raw: str) -> str:
    """Force a SQLAlchemy-compatible driver onto the connection string."""
    url = _clean(raw)
    if not url:
        return ""
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://") :]
    if url.startswith("postgresql://"):
        url = "postgresql+psycopg2://" + url[len("postgresql://") :]
    return url


class Settings:
    """Runtime settings resolved once from the process environment."""

    def __init__(self) -> None:
        self.app_name = "AutoAssist API"
        self.version = "1.0.0"
        self.environment = _clean(os.getenv("VERCEL_ENV")) or _clean(
            os.getenv("APP_ENV")
        ) or "development"

        # ── Database (Supabase / Neon PostgreSQL) ──────────────────────
        self.database_url = _normalize_database_url(os.getenv("DATABASE_URL"))
        self.database_sslmode = _clean(os.getenv("DATABASE_SSLMODE")) or "require"

        # ── Redis cache (Upstash REST or Redis protocol) ───────────────
        self.upstash_rest_url = _clean(
            os.getenv("UPSTASH_REDIS_REST_URL") or os.getenv("KV_REST_API_URL")
        ).rstrip("/")
        self.upstash_rest_token = _clean(
            os.getenv("UPSTASH_REDIS_REST_TOKEN") or os.getenv("KV_REST_API_TOKEN")
        )
        self.redis_url = _clean(os.getenv("REDIS_URL"))
        self.cache_ttl = int(_clean(os.getenv("CACHE_TTL_SECONDS")) or "300")
        self.cache_enabled = os.getenv("CACHE_ENABLED", "true").lower() not in {
            "0",
            "false",
            "no",
        }

        # ── Auth ───────────────────────────────────────────────────────
        self.jwt_secret = _clean(os.getenv("JWT_SECRET")) or "autoassist-dev-secret-change-me"
        self.jwt_algorithm = "HS256"
        self.jwt_expires_hours = int(_clean(os.getenv("JWT_EXPIRES_HOURS")) or "720")

        # ── CORS ───────────────────────────────────────────────────────
        raw_origins = _clean(os.getenv("CORS_ORIGINS"))
        self.cors_origins = (
            [o.strip() for o in raw_origins.split(",") if o.strip()]
            if raw_origins
            else ["*"]
        )

        # ── Seed demo data on first boot ───────────────────────────────
        self.seed_on_start = os.getenv("SEED_ON_START", "true").lower() not in {
            "0",
            "false",
            "no",
        }

    @property
    def is_production(self) -> bool:
        return self.environment.lower() in {"production", "preview"}

    @property
    def database_configured(self) -> bool:
        return bool(self.database_url)

    @property
    def redis_configured(self) -> bool:
        return bool(self.upstash_rest_url and self.upstash_rest_token) or bool(
            self.redis_url
        )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()

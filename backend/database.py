"""SQLAlchemy engine/session wiring for PostgreSQL (Neon/Supabase)."""

from __future__ import annotations

import logging
from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker
from sqlalchemy.pool import NullPool

from .config import get_settings

logger = logging.getLogger("autoassist.db")


class Base(DeclarativeBase):
    """Declarative base shared by every ORM model."""


_engine: Engine | None = None
_SessionLocal: sessionmaker[Session] | None = None
_schema_ready = False


def _build_engine() -> Engine:
    settings = get_settings()
    url = settings.database_url
    if not url:
        raise RuntimeError(
            "DATABASE_URL is not configured. Set it to your Supabase/Neon "
            "PostgreSQL connection string."
        )

    connect_args: dict[str, object] = {}
    kwargs: dict[str, object] = {}

    if url.startswith("sqlite"):
        connect_args["check_same_thread"] = False
    else:
        connect_args["sslmode"] = settings.database_sslmode
        # Serverless functions are short-lived: never keep idle connections.
        kwargs["poolclass"] = NullPool

    return create_engine(
        url,
        connect_args=connect_args,
        pool_pre_ping=True,
        future=True,
        **kwargs,
    )


def get_engine() -> Engine:
    global _engine
    if _engine is None:
        _engine = _build_engine()
    return _engine


def get_session_factory() -> sessionmaker[Session]:
    global _SessionLocal
    if _SessionLocal is None:
        _SessionLocal = sessionmaker(
            bind=get_engine(), autoflush=False, autocommit=False, expire_on_commit=False
        )
    return _SessionLocal


def reset_engine() -> None:
    """Drop cached engine/session (used by the test-suite)."""
    global _engine, _SessionLocal, _schema_ready
    if _engine is not None:
        _engine.dispose()
    _engine = None
    _SessionLocal = None
    _schema_ready = False


@contextmanager
def session_scope() -> Iterator[Session]:
    session = get_session_factory()()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


def get_db() -> Iterator[Session]:
    """FastAPI dependency yielding a database session."""
    session = get_session_factory()()
    try:
        yield session
    finally:
        session.close()


def ensure_schema() -> None:
    """Create tables and seed baseline catalog rows exactly once per process."""
    global _schema_ready
    if _schema_ready:
        return

    from . import models  # noqa: F401  (register models with the metadata)
    from .seed import seed_catalog

    engine = get_engine()
    Base.metadata.create_all(bind=engine)

    if get_settings().seed_on_start:
        with session_scope() as session:
            seed_catalog(session)

    _schema_ready = True


def database_healthy() -> bool:
    from sqlalchemy import text

    try:
        with get_engine().connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception as exc:  # pragma: no cover - depends on live infra
        logger.warning("Database health check failed: %s", exc)
        return False

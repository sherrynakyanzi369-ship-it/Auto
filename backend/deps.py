"""Shared FastAPI dependencies."""

from __future__ import annotations

from typing import Iterator

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session

from .database import ensure_schema, get_session_factory
from .models import User
from .security import decode_access_token

_bearer = HTTPBearer(auto_error=False)


def get_db() -> Iterator[Session]:
    """Yield a DB session, creating the schema on first use.

    Raises HTTP 503 when PostgreSQL is not configured so the client gets a
    clear, actionable error instead of an opaque 500.
    """
    try:
        ensure_schema()
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc

    session = get_session_factory()()
    try:
        yield session
    finally:
        session.close()


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: Session = Depends(get_db),
) -> User:
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required. Please sign in to continue.",
        )

    payload = decode_access_token(credentials.credentials)
    if not payload or not payload.get("sub"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired. Please sign in again.",
        )

    user = session.scalar(select(User).where(User.id == str(payload["sub"])))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Account not found. Please sign in again.",
        )
    return user

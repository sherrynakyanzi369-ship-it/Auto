"""Authentication endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..cache import cache_delete
from ..deps import get_current_user, get_db
from ..models import User
from ..schemas import AuthOut, LoginIn, RegisterIn, user_out
from ..security import create_access_token, hash_password, verify_password

router = APIRouter(prefix="/api/auth", tags=["auth"])

_DEMO_EMAIL = "demo@autoassist.app"
_DEMO_PASSWORD = "demo1234"


def _issue(user: User) -> dict:
    token = create_access_token(user.id, {"email": user.email})
    return {"token": token, "user": user_out(user)}


@router.post("/register", response_model=AuthOut, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterIn, session: Session = Depends(get_db)) -> dict:
    existing = session.scalar(select(User).where(User.email == payload.email))
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists. Try signing in.",
        )

    user = User(
        name=payload.name.strip(),
        email=payload.email,
        phone=payload.phone.strip(),
        password_hash=hash_password(payload.password),
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    cache_delete(f"autoassist:user:{user.email}")
    return _issue(user)


@router.post("/login", response_model=AuthOut)
def login(payload: LoginIn, session: Session = Depends(get_db)) -> dict:
    email = payload.email.strip().lower()
    user = session.scalar(select(User).where(User.email == email))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password. Please register first.",
        )
    return _issue(user)


@router.post("/demo", response_model=AuthOut)
def demo_login(session: Session = Depends(get_db)) -> dict:
    """Create (or reuse) a demo account and return a session for quick demos."""
    user = session.scalar(select(User).where(User.email == _DEMO_EMAIL))
    if user is None:
        user = User(
            name="Demo Driver",
            email=_DEMO_EMAIL,
            phone="+256 700 123 456",
            password_hash=hash_password(_DEMO_PASSWORD),
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    return _issue(user)


@router.get("/me", response_model=AuthOut)
def me(user: User = Depends(get_current_user)) -> dict:
    return _issue(user)


@router.post("/logout")
def logout() -> dict:
    # JWTs are stateless; the client discards the token.
    return {"ok": True}

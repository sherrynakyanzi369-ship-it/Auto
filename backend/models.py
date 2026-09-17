"""SQLAlchemy ORM models."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    JSON,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def _new_id(prefix: str) -> str:
    return f"{prefix}-{uuid.uuid4().hex[:12]}"


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(48), primary_key=True, default=lambda: _new_id("usr"))
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    phone: Mapped[str] = mapped_column(String(40), default="")
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)

    vehicles: Mapped[list["Vehicle"]] = relationship(
        back_populates="owner", cascade="all, delete-orphan"
    )
    requests: Mapped[list["AssistanceRequest"]] = relationship(
        back_populates="owner", cascade="all, delete-orphan"
    )


class Vehicle(Base):
    __tablename__ = "vehicles"

    id: Mapped[str] = mapped_column(String(48), primary_key=True, default=lambda: _new_id("veh"))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    make: Mapped[str] = mapped_column(String(80), default="")
    model: Mapped[str] = mapped_column(String(80), default="")
    year: Mapped[str] = mapped_column(String(12), default="")
    plate: Mapped[str] = mapped_column(String(40), default="")
    color: Mapped[str] = mapped_column(String(40), default="")
    type: Mapped[str] = mapped_column(String(60), default="")
    fuel_type: Mapped[str] = mapped_column(String(40), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)

    owner: Mapped[User] = relationship(back_populates="vehicles")


class AssistanceRequest(Base):
    __tablename__ = "assistance_requests"

    id: Mapped[str] = mapped_column(String(48), primary_key=True, default=lambda: _new_id("req"))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    vehicle_name: Mapped[str] = mapped_column(String(140), default="")
    issue_type: Mapped[str] = mapped_column(String(120), default="")
    description: Mapped[str] = mapped_column(Text, default="")
    location_label: Mapped[str] = mapped_column(String(255), default="")
    latitude: Mapped[float] = mapped_column(Float, default=0.0)
    longitude: Mapped[float] = mapped_column(Float, default=0.0)
    status: Mapped[str] = mapped_column(String(40), default="Pending")
    mechanic_name: Mapped[str] = mapped_column(String(140), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)

    owner: Mapped[User] = relationship(back_populates="requests")


class Mechanic(Base):
    __tablename__ = "mechanics"

    id: Mapped[str] = mapped_column(String(48), primary_key=True)
    name: Mapped[str] = mapped_column(String(120), default="")
    business_name: Mapped[str] = mapped_column(String(160), default="")
    specialty: Mapped[str] = mapped_column(String(120), default="", index=True)
    services: Mapped[list] = mapped_column(JSON, default=list)
    rating: Mapped[float] = mapped_column(Float, default=0.0)
    review_count: Mapped[int] = mapped_column(Integer, default=0)
    available: Mapped[bool] = mapped_column(Boolean, default=True)
    phone: Mapped[str] = mapped_column(String(40), default="")
    address: Mapped[str] = mapped_column(String(255), default="")
    latitude: Mapped[float] = mapped_column(Float, default=0.0)
    longitude: Mapped[float] = mapped_column(Float, default=0.0)
    experience: Mapped[str] = mapped_column(String(40), default="")


class SparePart(Base):
    __tablename__ = "spare_parts"

    id: Mapped[str] = mapped_column(String(48), primary_key=True)
    name: Mapped[str] = mapped_column(String(160), default="", index=True)
    category: Mapped[str] = mapped_column(String(80), default="", index=True)
    price: Mapped[float] = mapped_column(Float, default=0.0)
    supplier: Mapped[str] = mapped_column(String(160), default="")
    supplier_area: Mapped[str] = mapped_column(String(120), default="")
    in_stock: Mapped[bool] = mapped_column(Boolean, default=True)
    vehicle_compat: Mapped[str] = mapped_column(String(200), default="")

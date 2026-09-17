"""Vehicle garage endpoints (per authenticated user)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..cache import cache_delete, cache_get_json, cache_set_json
from ..deps import get_current_user, get_db
from ..models import User, Vehicle
from ..schemas import VehicleIn, vehicle_out

router = APIRouter(prefix="/api/vehicles", tags=["vehicles"])


def _cache_key(user_id: str) -> str:
    return f"autoassist:vehicles:{user_id}"


@router.get("")
def list_vehicles(
    user: User = Depends(get_current_user), session: Session = Depends(get_db)
) -> list[dict]:
    try:
        rows = session.scalars(
            select(Vehicle).where(Vehicle.user_id == user.id).order_by(Vehicle.created_at)
        ).all()
    except Exception as exc:  # pragma: no cover - live infra only
        cached = cache_get_json(_cache_key(user.id))
        if cached is not None:
            return cached
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database unavailable: {exc}",
        ) from exc

    payload = [vehicle_out(v) for v in rows]
    cache_set_json(_cache_key(user.id), payload)
    return payload


@router.post("", status_code=status.HTTP_201_CREATED)
def add_vehicle(
    payload: VehicleIn,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> dict:
    vehicle = Vehicle(
        user_id=user.id,
        make=payload.make,
        model=payload.model,
        year=payload.year,
        plate=payload.plate,
        color=payload.color,
        type=payload.type,
        fuel_type=payload.fuelType,
    )
    session.add(vehicle)
    session.commit()
    session.refresh(vehicle)
    cache_delete(_cache_key(user.id))
    return vehicle_out(vehicle)


@router.delete("/{vehicle_id}")
def remove_vehicle(
    vehicle_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> dict:
    vehicle = session.scalar(
        select(Vehicle).where(Vehicle.id == vehicle_id, Vehicle.user_id == user.id)
    )
    if vehicle is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehicle not found.")
    session.delete(vehicle)
    session.commit()
    cache_delete(_cache_key(user.id))
    return {"ok": True}

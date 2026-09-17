"""Read-only mechanics & spare-parts catalog (Redis cached)."""

from __future__ import annotations

import math

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..cache import cache_get_json, cache_set_json
from ..deps import get_db
from ..models import Mechanic, SparePart
from ..schemas import mechanic_out, part_out

router = APIRouter(prefix="/api", tags=["catalog"])


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    radius = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    h = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2) ** 2
    )
    return radius * 2 * math.asin(math.sqrt(h))


@router.get("/mechanics")
def list_mechanics(
    lat: float = Query(0.3476),
    lng: float = Query(32.5825),
    query: str = Query(""),
    specialty: str = Query(""),
    radius_km: float = Query(60.0),
    session: Session = Depends(get_db),
) -> list[dict]:
    cache_key = (
        f"autoassist:mechanics:{lat:.4f}:{lng:.4f}:{query.strip().lower()}:"
        f"{specialty.strip().lower()}:{radius_km}"
    )
    cached = cache_get_json(cache_key)
    if cached is not None:
        return cached

    try:
        rows = session.scalars(select(Mechanic)).all()
    except Exception as exc:  # pragma: no cover - live infra only
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database unavailable: {exc}",
        ) from exc

    items: list[tuple[Mechanic, float]] = []
    for mechanic in rows:
        distance = _haversine(lat, lng, mechanic.latitude, mechanic.longitude)
        if distance > radius_km:
            continue
        items.append((mechanic, distance))

    if specialty.strip():
        needle = specialty.strip().lower()
        items = [(m, d) for m, d in items if needle in m.specialty.lower()]

    if query.strip():
        needle = query.strip().lower()
        items = [
            (m, d)
            for m, d in items
            if needle in m.name.lower()
            or needle in m.business_name.lower()
            or needle in m.specialty.lower()
            or any(needle in s.lower() for s in (m.services or []))
        ]

    items.sort(key=lambda pair: pair[1])
    payload = [mechanic_out(m, d) for m, d in items]
    cache_set_json(cache_key, payload)
    return payload


@router.get("/parts")
def list_parts(
    query: str = Query(""),
    category: str = Query("All"),
    session: Session = Depends(get_db),
) -> list[dict]:
    cache_key = f"autoassist:parts:{query.strip().lower()}:{category.strip().lower()}"
    cached = cache_get_json(cache_key)
    if cached is not None:
        return cached

    try:
        stmt = select(SparePart)
        if category and category != "All":
            stmt = stmt.where(SparePart.category == category)
        rows = session.scalars(stmt).all()
    except Exception as exc:  # pragma: no cover - live infra only
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database unavailable: {exc}",
        ) from exc

    if query.strip():
        needle = query.strip().lower()
        rows = [
            p
            for p in rows
            if needle in p.name.lower()
            or needle in p.category.lower()
            or needle in p.supplier.lower()
            or needle in p.vehicle_compat.lower()
        ]

    payload = [part_out(p) for p in rows]
    cache_set_json(cache_key, payload)
    return payload


@router.get("/specialties")
def list_specialties(session: Session = Depends(get_db)) -> list[str]:
    cached = cache_get_json("autoassist:specialties")
    if cached is not None:
        return cached

    rows = session.scalars(select(Mechanic)).all()
    seen: list[str] = []
    for mechanic in rows:
        if mechanic.specialty and mechanic.specialty not in seen:
            seen.append(mechanic.specialty)
    cache_set_json("autoassist:specialties", seen)
    return seen

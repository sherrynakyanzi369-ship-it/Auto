"""Roadside assistance request endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..cache import cache_delete, cache_get_json, cache_set_json
from ..deps import get_current_user, get_db
from ..models import AssistanceRequest, User
from ..schemas import RequestIn, RequestStatusIn, request_out

router = APIRouter(prefix="/api/requests", tags=["assistance"])


def _cache_key(user_id: str) -> str:
    return f"autoassist:requests:{user_id}"


@router.get("")
def list_requests(
    user: User = Depends(get_current_user), session: Session = Depends(get_db)
) -> list[dict]:
    try:
        rows = session.scalars(
            select(AssistanceRequest)
            .where(AssistanceRequest.user_id == user.id)
            .order_by(AssistanceRequest.created_at.desc())
        ).all()
    except Exception as exc:  # pragma: no cover - live infra only
        cached = cache_get_json(_cache_key(user.id))
        if cached is not None:
            return cached
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database unavailable: {exc}",
        ) from exc

    payload = [request_out(r) for r in rows]
    cache_set_json(_cache_key(user.id), payload)
    return payload


@router.post("", status_code=status.HTTP_201_CREATED)
def create_request(
    payload: RequestIn,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> dict:
    request = AssistanceRequest(
        user_id=user.id,
        vehicle_name=payload.vehicleName,
        issue_type=payload.issueType,
        description=payload.description,
        location_label=payload.locationLabel,
        latitude=payload.latitude,
        longitude=payload.longitude,
        status=payload.status or "Pending",
        mechanic_name=payload.mechanicName,
    )
    session.add(request)
    session.commit()
    session.refresh(request)
    cache_delete(_cache_key(user.id))
    return request_out(request)


@router.patch("/{request_id}")
def update_status(
    request_id: str,
    payload: RequestStatusIn,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> dict:
    request = session.scalar(
        select(AssistanceRequest).where(
            AssistanceRequest.id == request_id,
            AssistanceRequest.user_id == user.id,
        )
    )
    if request is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Request not found.")
    request.status = payload.status
    session.commit()
    session.refresh(request)
    cache_delete(_cache_key(user.id))
    return request_out(request)

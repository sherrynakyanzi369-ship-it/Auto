"""Pydantic request/response schemas.

Field names intentionally mirror the Dart models (camelCase) so the Flutter
client can serialize/deserialize with zero mapping code.
"""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field, field_validator

from . import models


# ── Auth ────────────────────────────────────────────────────────────
class RegisterIn(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    email: str = Field(min_length=3, max_length=255)
    phone: str = ""
    password: str = Field(min_length=6, max_length=200)

    @field_validator("email")
    @classmethod
    def _valid_email(cls, value: str) -> str:
        cleaned = value.strip().lower()
        if "@" not in cleaned or "." not in cleaned.split("@")[-1]:
            raise ValueError("Enter a valid email address")
        return cleaned


class LoginIn(BaseModel):
    email: str = Field(min_length=3, max_length=255)
    password: str = Field(min_length=1, max_length=200)


class UserOut(BaseModel):
    uid: str
    name: str
    email: str
    phone: str


class AuthOut(BaseModel):
    token: str
    user: UserOut


# ── Vehicles ────────────────────────────────────────────────────────
class VehicleIn(BaseModel):
    make: str = ""
    model: str = ""
    year: str = ""
    plate: str = ""
    color: str = ""
    type: str = ""
    fuelType: str = ""


class VehicleOut(BaseModel):
    id: str
    make: str
    model: str
    year: str
    plate: str
    color: str
    type: str
    fuelType: str


# ── Assistance requests ─────────────────────────────────────────────
class RequestIn(BaseModel):
    vehicleName: str = ""
    issueType: str = ""
    description: str = ""
    locationLabel: str = ""
    latitude: float = 0.0
    longitude: float = 0.0
    status: str = "Pending"
    mechanicName: str = ""


class RequestOut(BaseModel):
    id: str
    vehicleName: str
    issueType: str
    description: str
    locationLabel: str
    latitude: float
    longitude: float
    status: str
    mechanicName: str
    createdAt: str


class RequestStatusIn(BaseModel):
    status: str = Field(min_length=1, max_length=40)


# ── Catalog ─────────────────────────────────────────────────────────
class MechanicOut(BaseModel):
    id: str
    name: str
    businessName: str
    specialty: str
    services: list[str]
    rating: float
    reviewCount: int
    available: bool
    phone: str
    address: str
    latitude: float
    longitude: float
    experience: str
    distanceKm: float = 0.0


class PartOut(BaseModel):
    id: str
    name: str
    category: str
    price: float
    supplier: str
    supplierArea: str
    inStock: bool
    vehicleCompat: str


# ── Serializers ─────────────────────────────────────────────────────
def user_out(user: models.User) -> dict[str, Any]:
    return {
        "uid": user.id,
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
    }


def vehicle_out(vehicle: models.Vehicle) -> dict[str, Any]:
    return {
        "id": vehicle.id,
        "make": vehicle.make,
        "model": vehicle.model,
        "year": vehicle.year,
        "plate": vehicle.plate,
        "color": vehicle.color,
        "type": vehicle.type,
        "fuelType": vehicle.fuel_type,
    }


def request_out(request: models.AssistanceRequest) -> dict[str, Any]:
    created = request.created_at
    return {
        "id": request.id,
        "vehicleName": request.vehicle_name,
        "issueType": request.issue_type,
        "description": request.description,
        "locationLabel": request.location_label,
        "latitude": request.latitude,
        "longitude": request.longitude,
        "status": request.status,
        "mechanicName": request.mechanic_name,
        "createdAt": created.isoformat() if created else "",
    }


def mechanic_out(mechanic: models.Mechanic, distance_km: float = 0.0) -> dict[str, Any]:
    return {
        "id": mechanic.id,
        "name": mechanic.name,
        "businessName": mechanic.business_name,
        "specialty": mechanic.specialty,
        "services": list(mechanic.services or []),
        "rating": mechanic.rating,
        "reviewCount": mechanic.review_count,
        "available": mechanic.available,
        "phone": mechanic.phone,
        "address": mechanic.address,
        "latitude": mechanic.latitude,
        "longitude": mechanic.longitude,
        "experience": mechanic.experience,
        "distanceKm": round(distance_km, 3),
    }


def part_out(part: models.SparePart) -> dict[str, Any]:
    return {
        "id": part.id,
        "name": part.name,
        "category": part.category,
        "price": part.price,
        "supplier": part.supplier,
        "supplierArea": part.supplier_area,
        "inStock": part.in_stock,
        "vehicleCompat": part.vehicle_compat,
    }

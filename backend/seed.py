"""Baseline catalog data seeded into PostgreSQL on first boot."""

from __future__ import annotations

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .models import Mechanic, SparePart

MECHANICS: list[dict] = [
    {
        "id": "mec-001", "name": "Joseph Okello", "business_name": "Okello Auto Repairs",
        "specialty": "Engine & Transmission",
        "services": ["Engine repair", "Transmission service", "Diagnostics", "Clutch replacement"],
        "rating": 4.8, "review_count": 128, "available": True, "phone": "+256 772 111 001",
        "address": "Plot 12, Ntinda Road, Ntinda", "latitude": 0.3553, "longitude": 32.6010,
        "experience": "12 years",
    },
    {
        "id": "mec-002", "name": "Grace Namugera", "business_name": "Namugera Tyres & Battery Centre",
        "specialty": "Tyres & Batteries",
        "services": ["Tyre replacement", "Battery boost", "Battery replacement", "Wheel alignment"],
        "rating": 4.6, "review_count": 74, "available": True, "phone": "+256 782 220 002",
        "address": "Bukoto Street, Bukoto", "latitude": 0.3411, "longitude": 32.5947,
        "experience": "8 years",
    },
    {
        "id": "mec-003", "name": "David Ssemakula", "business_name": "Bwaise Vehicle Clinic",
        "specialty": "General Repairs",
        "services": ["General service", "Oil change", "Brake service", "Towing"],
        "rating": 4.4, "review_count": 52, "available": True, "phone": "+256 700 333 003",
        "address": "Kampala - Hoima Road, Bwaise", "latitude": 0.3550, "longitude": 32.5680,
        "experience": "10 years",
    },
    {
        "id": "mec-004", "name": "Ivan Kato", "business_name": "Wandegeya Auto Electricians",
        "specialty": "Auto Electrical",
        "services": ["Starter motors", "Alternators", "Wiring", "Battery diagnostics"],
        "rating": 4.7, "review_count": 41, "available": False, "phone": "+256 774 444 004",
        "address": "Makerere Hill Road, Wandegeya", "latitude": 0.3330, "longitude": 32.5744,
        "experience": "9 years",
    },
    {
        "id": "mec-005", "name": "Robert Mukasa", "business_name": "Nakawa Diesel Specialists",
        "specialty": "Diesel Engines",
        "services": ["Diesel injector service", "Turbo repair", "Engine overhaul", "Fuel pump repair"],
        "rating": 4.5, "review_count": 60, "available": True, "phone": "+256 788 555 005",
        "address": "Nakawa Market Road, Nakawa", "latitude": 0.3269, "longitude": 32.6119,
        "experience": "15 years",
    },
    {
        "id": "mec-006", "name": "Faridah Nabirye", "business_name": "Entebbe Road Body & Paint",
        "specialty": "Body Work & Paint",
        "services": ["Panel beating", "Spray painting", "Denting", "Underbody protection"],
        "rating": 4.3, "review_count": 33, "available": True, "phone": "+256 701 666 006",
        "address": "Entebbe Road, Ndeeba", "latitude": 0.2990, "longitude": 32.6170,
        "experience": "7 years",
    },
    {
        "id": "mec-007", "name": "Moses Lubega", "business_name": "Lubaga Brake & Suspension",
        "specialty": "Brakes & Suspension",
        "services": ["Brake pad replacement", "Disc machining", "Shock absorbers", "Tie rods"],
        "rating": 4.9, "review_count": 90, "available": True, "phone": "+256 755 777 007",
        "address": "Lubaga Road, Lubaga", "latitude": 0.3022, "longitude": 32.5617,
        "experience": "11 years",
    },
    {
        "id": "mec-008", "name": "Brian Wasswa", "business_name": "Mengo Mobile Mechanic Express",
        "specialty": "Mobile 24/7",
        "services": ["Mobile repairs", "Jump start", "Fuel delivery", "Tyre change", "Emergency calls"],
        "rating": 4.6, "review_count": 88, "available": True, "phone": "+256 777 888 008",
        "address": "Circular Road, Mengo", "latitude": 0.3032, "longitude": 32.5630,
        "experience": "6 years",
    },
]

SPARE_PARTS: list[dict] = [
    {"id": "prt-001", "name": "12V Car Battery (60Ah)", "category": "Batteries", "price": 450000,
     "supplier": "AutoMart Uganda", "supplier_area": "Kampala Road", "in_stock": True,
     "vehicle_compat": "Most saloon cars & SUVs"},
    {"id": "prt-002", "name": "Disc Brake Pads - Front", "category": "Brakes", "price": 85000,
     "supplier": "Lugogo Spares", "supplier_area": "Lugogo", "in_stock": True,
     "vehicle_compat": "Toyota, Nissan, Honda"},
    {"id": "prt-003", "name": "Engine Oil 5W-30 (4 Litres)", "category": "Lubricants", "price": 95000,
     "supplier": "Nakawa Auto Spares", "supplier_area": "Nakivubo", "in_stock": True,
     "vehicle_compat": "Petrol & diesel engines"},
    {"id": "prt-004", "name": "Spark Plug (set of 4)", "category": "Ignition", "price": 28000,
     "supplier": "City Auto Spares", "supplier_area": "Bombo Road", "in_stock": True,
     "vehicle_compat": "Petrol engines"},
    {"id": "prt-005", "name": "Engine Air Filter", "category": "Filters", "price": 22000,
     "supplier": "City Auto Spares", "supplier_area": "Bombo Road", "in_stock": True,
     "vehicle_compat": "Universal fit"},
    {"id": "prt-006", "name": "Clutch Disc & Pressure Plate Kit", "category": "Transmission",
     "price": 380000, "supplier": "Lugogo Spares", "supplier_area": "Lugogo", "in_stock": False,
     "vehicle_compat": "Toyota Corolla, Mitsubishi"},
    {"id": "prt-007", "name": "Tyre 205/55 R16", "category": "Tyres", "price": 340000,
     "supplier": "Kampala Tyre Depot", "supplier_area": "Kira Road", "in_stock": True,
     "vehicle_compat": "Sedans & compact SUVs"},
    {"id": "prt-008", "name": "Alternator (12V)", "category": "Electrical", "price": 520000,
     "supplier": "Nakawa Auto Spares", "supplier_area": "Nakivubo", "in_stock": True,
     "vehicle_compat": "Toyota, Daihatsu"},
    {"id": "prt-009", "name": "Radiator Coolant (5 Litres)", "category": "Cooling", "price": 45000,
     "supplier": "AutoMart Uganda", "supplier_area": "Kampala Road", "in_stock": True,
     "vehicle_compat": "All vehicle types"},
    {"id": "prt-010", "name": "Electric Fuel Pump", "category": "Fuel System", "price": 290000,
     "supplier": "City Auto Spares", "supplier_area": "Bombo Road", "in_stock": True,
     "vehicle_compat": "Fuel injection systems"},
    {"id": "prt-011", "name": "Rear Shock Absorber", "category": "Suspension", "price": 165000,
     "supplier": "Lugogo Spares", "supplier_area": "Lugogo", "in_stock": True,
     "vehicle_compat": "Toyota Corolla"},
    {"id": "prt-012", "name": "LED Headlight Bulb (H4)", "category": "Lighting", "price": 18000,
     "supplier": "Kampala Tyre Depot", "supplier_area": "Kira Road", "in_stock": True,
     "vehicle_compat": "Universal fit"},
]


def seed_catalog(session: Session) -> None:
    """Insert catalog rows only when their tables are empty (idempotent)."""
    if session.scalar(select(func.count()).select_from(Mechanic)) == 0:
        session.add_all(Mechanic(**row) for row in MECHANICS)

    if session.scalar(select(func.count()).select_from(SparePart)) == 0:
        session.add_all(SparePart(**row) for row in SPARE_PARTS)

    session.flush()

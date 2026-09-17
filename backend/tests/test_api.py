"""End-to-end API tests (SQLite + in-process cache)."""

from __future__ import annotations

from fastapi.testclient import TestClient

from backend.main import app

client = TestClient(app)


def _auth_headers() -> dict[str, str]:
    response = client.post(
        "/api/auth/register",
        json={
            "name": "Test Driver",
            "email": "tester@autoassist.app",
            "phone": "+256 700 000 000",
            "password": "secret123",
        },
    )
    if response.status_code == 409:
        response = client.post(
            "/api/auth/login",
            json={"email": "tester@autoassist.app", "password": "secret123"},
        )
    assert response.status_code in (200, 201), response.text
    return {"Authorization": f"Bearer {response.json()['token']}"}


def test_api_root_and_health() -> None:
    root = client.get("/api")
    assert root.status_code == 200
    assert root.json()["name"]

    health = client.get("/api/health")
    assert health.status_code == 200
    body = health.json()
    assert body["status"] == "ok"
    assert body["database"]["healthy"] is True


def test_register_login_and_me() -> None:
    headers = _auth_headers()
    me = client.get("/api/auth/me", headers=headers)
    assert me.status_code == 200
    assert me.json()["user"]["email"] == "tester@autoassist.app"


def test_duplicate_registration_conflicts() -> None:
    _auth_headers()
    duplicate = client.post(
        "/api/auth/register",
        json={
            "name": "Test Driver",
            "email": "tester@autoassist.app",
            "phone": "",
            "password": "secret123",
        },
    )
    assert duplicate.status_code == 409


def test_login_rejects_bad_password() -> None:
    _auth_headers()
    response = client.post(
        "/api/auth/login",
        json={"email": "tester@autoassist.app", "password": "wrong-password"},
    )
    assert response.status_code == 401


def test_protected_routes_require_auth() -> None:
    assert client.get("/api/vehicles").status_code == 401
    assert client.get("/api/requests").status_code == 401


def test_vehicle_lifecycle() -> None:
    headers = _auth_headers()
    created = client.post(
        "/api/vehicles",
        headers=headers,
        json={
            "make": "Toyota",
            "model": "Corolla",
            "year": "2018",
            "plate": "UBH 123X",
            "color": "Silver",
            "type": "Saloon",
            "fuelType": "Petrol",
        },
    )
    assert created.status_code == 201, created.text
    vehicle_id = created.json()["id"]

    listed = client.get("/api/vehicles", headers=headers)
    assert listed.status_code == 200
    assert any(v["id"] == vehicle_id for v in listed.json())

    deleted = client.delete(f"/api/vehicles/{vehicle_id}", headers=headers)
    assert deleted.status_code == 200


def test_assistance_request_lifecycle() -> None:
    headers = _auth_headers()
    created = client.post(
        "/api/requests",
        headers=headers,
        json={
            "vehicleName": "Toyota Corolla",
            "issueType": "Flat or punctured tyre",
            "description": "Front left tyre is flat",
            "locationLabel": "Kampala, Uganda",
            "latitude": 0.3476,
            "longitude": 32.5825,
        },
    )
    assert created.status_code == 201, created.text
    request_id = created.json()["id"]
    assert created.json()["status"] == "Pending"

    updated = client.patch(
        f"/api/requests/{request_id}", headers=headers, json={"status": "Completed"}
    )
    assert updated.status_code == 200
    assert updated.json()["status"] == "Completed"

    listed = client.get("/api/requests", headers=headers)
    assert listed.status_code == 200
    assert listed.json()[0]["id"] == request_id


def test_catalog_is_seeded() -> None:
    mechanics = client.get("/api/mechanics")
    assert mechanics.status_code == 200
    assert len(mechanics.json()) >= 8
    assert "distanceKm" in mechanics.json()[0]

    parts = client.get("/api/parts")
    assert parts.status_code == 200
    assert len(parts.json()) >= 12

    filtered = client.get("/api/mechanic" + "s", params={"specialty": "Diesel Engines"})
    assert filtered.status_code == 200
    assert all("Diesel" in m["specialty"] for m in filtered.json())


def test_demo_login() -> None:
    response = client.post("/api/auth/demo")
    assert response.status_code == 200
    assert response.json()["user"]["email"] == "demo@autoassist.app"

"""AutoAssist FastAPI application.

Deployed on Vercel as a single serverless function (see ``api/index.py``) and
served at ``/api/*`` from the same origin as the Flutter web build.
"""

from __future__ import annotations

import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .cache import cache_health
from .config import get_settings
from .database import database_healthy
from .routers import assistance, auth, catalog, vehicles

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("autoassist")

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    docs_url="/api/docs",
    openapi_url="/api/openapi.json",
    redoc_url=None,
)


@app.middleware("http")
async def normalize_path(request: Request, call_next):
    """Make the app resilient to Vercel function rewrites.

    Depending on the rewrite, the ASGI scope can arrive as ``/api/index`` or as
    the original ``/api/...`` path. Normalise everything to a ``/api`` prefix so
    routing always resolves.
    """
    path = request.scope.get("path", "") or "/"
    if path.startswith("/api/index"):
        path = path[len("/api/index") :] or "/"
    if not path.startswith("/api"):
        path = "/api" + ("" if path == "/" else path)
    if path != request.scope.get("path"):
        request.scope["path"] = path
        request.scope["raw_path"] = path.encode("utf-8")
    return await call_next(request)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(vehicles.router)
app.include_router(assistance.router)
app.include_router(catalog.router)


@app.get("/api")
def api_root() -> dict:
    return {
        "name": settings.app_name,
        "version": settings.version,
        "environment": settings.environment,
        "docs": "/api/docs",
    }


@app.get("/api/health")
def health() -> JSONResponse:
    db_ok = database_healthy() if settings.database_configured else False
    redis_ok = cache_health()
    status_code = 200 if db_ok else 503
    return JSONResponse(
        status_code=status_code,
        content={
            "status": "ok" if db_ok else "degraded",
            "version": settings.version,
            "environment": settings.environment,
            "database": {
                "configured": settings.database_configured,
                "healthy": db_ok,
            },
            "redis": {
                "configured": settings.redis_configured,
                "healthy": redis_ok,
            },
        },
    )

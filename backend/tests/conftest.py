"""Test configuration: run the API against a throwaway SQLite database."""

from __future__ import annotations

import os
import pathlib
import tempfile

_DB_PATH = pathlib.Path(tempfile.gettempdir()) / "autoassist_test.db"
if _DB_PATH.exists():
    _DB_PATH.unlink()

os.environ["DATABASE_URL"] = f"sqlite:///{_DB_PATH.as_posix()}"
os.environ["CACHE_ENABLED"] = "false"
os.environ["SEED_ON_START"] = "true"
os.environ["JWT_SECRET"] = "test-secret"
os.environ.pop("UPSTASH_REDIS_REST_URL", None)
os.environ.pop("UPSTASH_REDIS_REST_TOKEN", None)
os.environ.pop("REDIS_URL", None)

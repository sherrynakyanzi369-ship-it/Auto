"""Vercel serverless entrypoint.

Vercel's Python runtime loads the ASGI ``app`` object from this file. The
project root is added to ``sys.path`` so the ``backend`` package (which holds
the actual application code) can be imported at runtime.
"""

from __future__ import annotations

import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from backend.main import app  # noqa: E402,F401

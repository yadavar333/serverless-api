"""Shared utilities for all Lambda handlers (deployed as a Lambda Layer)."""

import json
import uuid
from datetime import datetime, timezone
from typing import Any


def generate_id() -> str:
    """Generate a unique bookmark ID."""
    return str(uuid.uuid4())


def now_iso() -> str:
    """Return current UTC time as ISO 8601 string."""
    return datetime.now(timezone.utc).isoformat()


def response(status_code: int, body: Any) -> dict:
    """Build an API Gateway proxy response."""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body, default=str),
    }


def error(status_code: int, message: str) -> dict:
    """Build an error API Gateway proxy response."""
    return response(status_code, {"error": message})


def parse_body(event: dict) -> dict:
    """Safely parse the Lambda event body."""
    body = event.get("body") or "{}"
    if isinstance(body, str):
        return json.loads(body)
    return body

"""POST /bookmarks — create a new bookmark."""

import os
import boto3
from utils import generate_id, now_iso, response, error, parse_body

TABLE = os.environ["TABLE_NAME"]
_db   = boto3.resource("dynamodb")
table = _db.Table(TABLE)


def handler(event, context):
    try:
        body = parse_body(event)
    except Exception:
        return error(400, "Invalid JSON body")

    url     = (body.get("url") or "").strip()
    title   = (body.get("title") or "").strip()
    user_id = (body.get("user_id") or "").strip()

    if not url:
        return error(400, "url is required")
    if not user_id:
        return error(400, "user_id is required")

    bookmark = {
        "id":         generate_id(),
        "user_id":    user_id,
        "url":        url,
        "title":      title or url,
        "created_at": now_iso(),
    }

    table.put_item(Item=bookmark)
    return response(201, bookmark)

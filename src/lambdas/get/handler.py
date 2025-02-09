"""GET /bookmarks/{id} — fetch a single bookmark by ID."""

import os
import boto3
from utils import response, error

TABLE = os.environ["TABLE_NAME"]
_db   = boto3.resource("dynamodb")
table = _db.Table(TABLE)


def handler(event, context):
    bookmark_id = (event.get("pathParameters") or {}).get("id")
    if not bookmark_id:
        return error(400, "id path parameter is required")

    result = table.get_item(Key={"id": bookmark_id})
    item   = result.get("Item")

    if not item:
        return error(404, f"Bookmark '{bookmark_id}' not found")

    return response(200, item)

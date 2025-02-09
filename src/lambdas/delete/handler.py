"""DELETE /bookmarks/{id} — delete a bookmark by ID."""

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

    # Check existence before deleting
    existing = table.get_item(Key={"id": bookmark_id}).get("Item")
    if not existing:
        return error(404, f"Bookmark '{bookmark_id}' not found")

    table.delete_item(Key={"id": bookmark_id})
    return response(200, {"message": f"Bookmark '{bookmark_id}' deleted"})

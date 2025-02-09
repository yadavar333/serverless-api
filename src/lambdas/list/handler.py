"""GET /bookmarks — list bookmarks, optionally filtered by user_id."""

import os
import boto3
from boto3.dynamodb.conditions import Key
from utils import response, error

TABLE = os.environ["TABLE_NAME"]
_db   = boto3.resource("dynamodb")
table = _db.Table(TABLE)


def handler(event, context):
    params  = event.get("queryStringParameters") or {}
    user_id = params.get("user_id", "").strip()

    try:
        if user_id:
            # Query the GSI for a specific user's bookmarks
            result = table.query(
                IndexName="user_id-index",
                KeyConditionExpression=Key("user_id").eq(user_id),
            )
        else:
            # Scan all bookmarks (small table — acceptable for demo)
            result = table.scan()
    except Exception as e:
        return error(500, str(e))

    items = result.get("Items", [])
    return response(200, {"bookmarks": items, "count": len(items)})

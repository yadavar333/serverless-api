"""Unit tests for Lambda handlers — DynamoDB mocked with unittest.mock."""

import json
import sys
import types
import unittest
from unittest.mock import MagicMock, patch

# ── Stub out boto3 so tests run without AWS credentials ───────────────────────
boto3_mock = MagicMock()
sys.modules['boto3'] = boto3_mock

# Make utils importable without the layer path
sys.path.insert(0, 'src/layer/python')

import os
os.environ['TABLE_NAME'] = 'test-table'


def _event(method='GET', path_params=None, body=None, qs=None):
    return {
        'httpMethod':        method,
        'pathParameters':    path_params or {},
        'queryStringParameters': qs or {},
        'body': json.dumps(body) if body else None,
    }


# ── utils tests ───────────────────────────────────────────────────────────────

from utils import generate_id, now_iso, response, error, parse_body


class TestUtils(unittest.TestCase):

    def test_generate_id_is_unique(self):
        ids = {generate_id() for _ in range(100)}
        self.assertEqual(len(ids), 100)

    def test_response_structure(self):
        res = response(200, {'key': 'value'})
        self.assertEqual(res['statusCode'], 200)
        self.assertIn('Content-Type', res['headers'])
        body = json.loads(res['body'])
        self.assertEqual(body['key'], 'value')

    def test_error_structure(self):
        res = error(404, 'Not found')
        self.assertEqual(res['statusCode'], 404)
        body = json.loads(res['body'])
        self.assertEqual(body['error'], 'Not found')

    def test_parse_body_from_string(self):
        event = {'body': '{"url": "https://example.com"}'}
        result = parse_body(event)
        self.assertEqual(result['url'], 'https://example.com')

    def test_parse_body_missing_returns_empty(self):
        result = parse_body({})
        self.assertEqual(result, {})


# ── create handler tests ──────────────────────────────────────────────────────

class TestCreateHandler(unittest.TestCase):

    def setUp(self):
        # Fresh import with mocked table
        import importlib
        self.table_mock = MagicMock()
        boto3_mock.resource.return_value.Table.return_value = self.table_mock
        import src.lambdas.create.handler as m
        importlib.reload(m)
        self.handler = m.handler

    def test_create_returns_201(self):
        event = _event('POST', body={'url': 'https://example.com', 'user_id': 'u1'})
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 201)
        body = json.loads(res['body'])
        self.assertEqual(body['url'], 'https://example.com')
        self.assertIn('id', body)

    def test_create_missing_url_returns_400(self):
        event = _event('POST', body={'user_id': 'u1'})
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 400)

    def test_create_missing_user_id_returns_400(self):
        event = _event('POST', body={'url': 'https://x.com'})
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 400)


# ── get handler tests ─────────────────────────────────────────────────────────

class TestGetHandler(unittest.TestCase):

    def setUp(self):
        import importlib
        self.table_mock = MagicMock()
        boto3_mock.resource.return_value.Table.return_value = self.table_mock
        import src.lambdas.get.handler as m
        importlib.reload(m)
        self.handler = m.handler

    def test_get_existing_returns_200(self):
        self.table_mock.get_item.return_value = {
            'Item': {'id': 'abc', 'url': 'https://example.com', 'user_id': 'u1'}
        }
        event = _event('GET', path_params={'id': 'abc'})
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 200)
        body = json.loads(res['body'])
        self.assertEqual(body['id'], 'abc')

    def test_get_missing_returns_404(self):
        self.table_mock.get_item.return_value = {}
        event = _event('GET', path_params={'id': 'no-such-id'})
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 404)

    def test_get_no_id_returns_400(self):
        event = _event('GET')
        res   = self.handler(event, {})
        self.assertEqual(res['statusCode'], 400)


if __name__ == '__main__':
    unittest.main()

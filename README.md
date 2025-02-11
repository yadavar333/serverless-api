# Serverless REST API

Four Lambda functions (create/get/list/delete bookmarks) + DynamoDB + API Gateway HTTP API, all provisioned with Terraform. Each Lambda has its own least-privilege IAM role. Shared utility code is deployed as a Lambda Layer.

## Stack
AWS Lambda · API Gateway (HTTP API v2) · DynamoDB · IAM · CloudWatch · Terraform · Python 3.11 · boto3

## Architecture

```
Client
  │
  ▼
API Gateway HTTP API  (prod stage)
  ├── POST   /bookmarks        ──►  bookmarks-prod-create  ──► DynamoDB PutItem
  ├── GET    /bookmarks/{id}   ──►  bookmarks-prod-get     ──► DynamoDB GetItem
  ├── GET    /bookmarks        ──►  bookmarks-prod-list    ──► DynamoDB Query/Scan
  └── DELETE /bookmarks/{id}   ──►  bookmarks-prod-delete  ──► DynamoDB DeleteItem

Each Lambda:
  - Has its own least-privilege IAM role (only the DynamoDB action it needs)
  - Loads shared utils from Lambda Layer (generate_id, response, error, parse_body)
  - Writes structured logs to its own CloudWatch Log Group (14-day retention)

DynamoDB Table:
  - Hash key  : id (String, UUID)
  - GSI       : user_id-index  →  enables efficient per-user queries
  - Billing   : PAY_PER_REQUEST (no capacity planning)
  - PITR      : enabled
```

## Project Structure

```
serverless-api/
├── terraform/
│   ├── main.tf            # provider, required_providers
│   ├── variables.tf       # region, project, environment
│   ├── dynamodb.tf        # DynamoDB table + GSI
│   ├── iam.tf             # 4 IAM roles + policies (least-privilege)
│   ├── lambda_layer.tf    # shared utils layer
│   ├── lambda.tf          # 4 Lambda functions + archive_file zipping
│   ├── api_gateway.tf     # HTTP API + routes + integrations + permissions
│   ├── cloudwatch.tf      # Log groups (Lambda × 4 + API GW)
│   └── outputs.tf         # API endpoint URL
├── src/
│   ├── layer/python/
│   │   └── utils.py       # generate_id, response, error, parse_body
│   └── lambdas/
│       ├── create/handler.py
│       ├── get/handler.py
│       ├── list/handler.py
│       └── delete/handler.py
├── tests/
│   └── test_handlers.py   # 11 unit tests (boto3 mocked)
└── builds/                # Terraform writes zips here (gitignored)
```

## Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform uses `archive_file` to zip Lambda code automatically — no manual build step needed.

## API Usage

After `terraform apply`, get the endpoint from outputs:

```bash
export API=$(terraform output -raw api_endpoint)

# Create bookmark
curl -X POST $API/bookmarks \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com","title":"Example","user_id":"user-123"}'

# List all bookmarks
curl $API/bookmarks

# List by user
curl "$API/bookmarks?user_id=user-123"

# Get single
curl $API/bookmarks/{id}

# Delete
curl -X DELETE $API/bookmarks/{id}
```

## Tests

```bash
pip install pytest
pytest tests/ -v
# 11 passed — utils + create + get handler tests (boto3 mocked)
```

## Cost Estimate (light usage — ~10k req/month)

| Service | Cost |
|---------|------|
| Lambda (128 MB, <1s) | ~$0.00 (free tier) |
| API Gateway HTTP API | ~$0.01 |
| DynamoDB on-demand | ~$0.01 |
| CloudWatch Logs | ~$0.01 |
| **Total** | **< $0.05 / month** |

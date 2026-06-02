#!/bin/sh
set -e

ALIAS="storage"

echo "Waiting for MinIO to be ready..."
mc alias set $ALIAS http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

echo "Creating buckets..."
mc mb --ignore-existing $ALIAS/vexa
mc mb --ignore-existing $ALIAS/churchafrica
mc mb --ignore-existing $ALIAS/zeroclaw

echo "Writing bucket policies..."
cat > /tmp/vexa-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:*"],"Resource":["arn:aws:s3:::vexa","arn:aws:s3:::vexa/*"]}]}
EOF

cat > /tmp/ca-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:*"],"Resource":["arn:aws:s3:::churchafrica","arn:aws:s3:::churchafrica/*"]}]}
EOF

cat > /tmp/zc-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:*"],"Resource":["arn:aws:s3:::zeroclaw","arn:aws:s3:::zeroclaw/*"]}]}
EOF

echo "Creating service accounts (idempotent)..."

mc admin user svcacct info $ALIAS "$MINIO_VEXA_ACCESS_KEY" 2>/dev/null || \
  mc admin user svcacct add \
    --access-key "$MINIO_VEXA_ACCESS_KEY" \
    --secret-key "$MINIO_VEXA_SECRET_KEY" \
    --policy /tmp/vexa-policy.json \
    $ALIAS "$MINIO_ROOT_USER"

mc admin user svcacct info $ALIAS "$MINIO_CA_ACCESS_KEY" 2>/dev/null || \
  mc admin user svcacct add \
    --access-key "$MINIO_CA_ACCESS_KEY" \
    --secret-key "$MINIO_CA_SECRET_KEY" \
    --policy /tmp/ca-policy.json \
    $ALIAS "$MINIO_ROOT_USER"

mc admin user svcacct info $ALIAS "$MINIO_ZC_ACCESS_KEY" 2>/dev/null || \
  mc admin user svcacct add \
    --access-key "$MINIO_ZC_ACCESS_KEY" \
    --secret-key "$MINIO_ZC_SECRET_KEY" \
    --policy /tmp/zc-policy.json \
    $ALIAS "$MINIO_ROOT_USER"

echo "MinIO initialization complete."

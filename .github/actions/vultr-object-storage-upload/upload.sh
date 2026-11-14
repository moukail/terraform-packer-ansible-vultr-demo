#!/usr/bin/env bash

set -Eeuo pipefail

export AWS_ACCESS_KEY_ID="$INPUT_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_SECRET_KEY"
export AWS_DEFAULT_REGION="$INPUT_REGION"

# --------------------------------------------------
# Upload RAW image
# --------------------------------------------------

echo "Uploading image to Vultr Object Storage..."

OBJECT_KEY="${INPUT_PREFIX}/${INPUT_IMAGE}"

aws s3 cp \
  "$INPUT_IMAGE" \
  "s3://${INPUT_BUCKET}/${OBJECT_KEY}" \
  --endpoint-url "$INPUT_ENDPOINT" \
  --region "$INPUT_REGION" \
  --content-type application/octet-stream \
  --only-show-errors

# --------------------------------------------------
# Generate public URL
# --------------------------------------------------
IMAGE_URL="test"
# --------------------------------------------------
# GitHub Actions outputs
# --------------------------------------------------

{
  echo "image-url=${IMAGE_URL}"
  echo "object-key=${OBJECT_KEY}"
} >> "$GITHUB_OUTPUT"

echo "--------------------------------------"
echo "Upload completed successfully"
echo "--------------------------------------"
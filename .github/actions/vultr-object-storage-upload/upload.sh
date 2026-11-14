#!/usr/bin/env bash

set -Eeuo pipefail

export AWS_ACCESS_KEY_ID="$INPUT_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_SECRET_KEY"
export AWS_DEFAULT_REGION="$INPUT_REGION"

# --------------------------------------------------
# Upload RAW image
# --------------------------------------------------

echo "Uploading image to Vultr Object Storage..."

OBJECT_KEY="${INPUT_PREFIX}/${IMAGE_NAME}"

aws s3 cp \
  "$IMAGE_PATH" \
  "s3://${INPUT_BUCKET}/${OBJECT_KEY}" \
  --endpoint-url "$INPUT_ENDPOINT" \
  --region "$INPUT_REGION" \
  --content-type application/octet-stream \
  --only-show-errors

# --------------------------------------------------
# Set object ACL
# --------------------------------------------------

  echo "Setting public-read ACL..."

  aws s3api put-object-acl \
    --bucket "$INPUT_BUCKET" \
    --key "$OBJECT_KEY" \
    --acl public-read \
    --endpoint-url "$INPUT_ENDPOINT" \
    --region "$INPUT_REGION"

source .github/actions/vultr-object-storage-upload/image_url.sh

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
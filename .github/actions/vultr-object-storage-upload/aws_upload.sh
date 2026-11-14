#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID="$INPUT_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_SECRET_KEY"
export AWS_DEFAULT_REGION="$INPUT_REGION"

# --------------------------------------------------
# Upload RAW image
# --------------------------------------------------

echo "Uploading image to Vultr Object Storage..."

OBJECT_KEY="${INPUT_PREFIX}/${IMAGE_NAME}"

ACCESS_POINT_ARN="arn:aws:s3:eu-west-1:${AWS_ACCOUNT_ID}:accesspoint/${ACCESS_POINT_NAME}"

aws s3 cp \
  "$INPUT_IMAGE" \
  "s3://${ACCESS_POINT_ARN}/${OBJECT_KEY}" \
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
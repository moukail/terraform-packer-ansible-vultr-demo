#!/usr/bin/env bash

set -Eeuo pipefail

export AWS_ACCESS_KEY_ID="$INPUT_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_SECRET_KEY"
export AWS_DEFAULT_REGION="$INPUT_REGION"

OBJECT_KEY="${INPUT_PREFIX}/${IMAGE_NAME}"

if aws s3api head-object \
    --bucket "$INPUT_BUCKET" \
    --key "$OBJECT_KEY" \
    --endpoint-url "$INPUT_ENDPOINT" \
    --region "$INPUT_REGION" \
    >/dev/null 2>&1; then

    source .github/actions/vultr-object-storage-upload/image_url.sh

    {
        echo "image-url=${IMAGE_URL}"
        echo "object-key=${OBJECT_KEY}"
        echo "image-exists=true" >> "$GITHUB_OUTPUT"
        echo "Image already exists: $OBJECT_KEY"
    } >> "$GITHUB_OUTPUT"

else

    echo "image-exists=false" >> "$GITHUB_OUTPUT"
    echo "Image does not exist: $OBJECT_KEY"

fi
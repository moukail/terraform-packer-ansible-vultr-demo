#!/usr/bin/env bash

# --------------------------------------------------
# Generate public URL
# --------------------------------------------------

ENDPOINT="${INPUT_ENDPOINT%/}"
BUCKET="${INPUT_BUCKET}"

# Vultr virtual-hosted-style URL
IMAGE_URL="${ENDPOINT/https:\/\//https://${BUCKET}.}"
IMAGE_URL="${IMAGE_URL/http:\/\//http://${BUCKET}.}"
IMAGE_URL="${IMAGE_URL}/${OBJECT_KEY}"

if [[ "$INPUT_PUBLIC_READ" == "true" ]]; then

  echo "Checking public URL..."

  HTTP_STATUS=$(curl \
    --silent \
    --output /dev/null \
    --write-out '%{http_code}' \
    --location \
    --connect-timeout 15 \
    --max-time 60 \
    --head \
    "$IMAGE_URL")

  if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "::error::Public image URL returned HTTP $HTTP_STATUS"
    exit 1
  fi

else

  IMAGE_URL=""

fi
#!/bin/bash

set -ouex pipefail

# Input validation
VARIANT=${1:?VARIANT required (base|desktop|laptop)}
IMAGE_NAME=${2:?IMAGE_NAME required}
IMAGE_REGISTRY=${3:?IMAGE_REGISTRY required}

FULL_IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}"
TIMESTAMP=$(date -u +%Y%m%d)

echo "Pushing ${VARIANT} variant of ${FULL_IMAGE}"

buildah push "${FULL_IMAGE}:${VARIANT}"
buildah push "${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

echo "Successfully pushed ${VARIANT} variant with tags:"
echo "  - ${FULL_IMAGE}:${VARIANT}"
echo "  - ${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

#!/bin/bash

set -ouex pipefail

# Input validation
VARIANT=${1:?VARIANT required (base|desktop|laptop)}
IMAGE_NAME=${2:?IMAGE_NAME required}
IMAGE_REGISTRY=${3:?IMAGE_REGISTRY required}

FULL_IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}"
TIMESTAMP=$(date -u +%Y%m%d)

echo "Building ${VARIANT} variant of ${FULL_IMAGE}"

buildah build --target="${VARIANT}" -t "${FULL_IMAGE}:${VARIANT}" .
buildah tag "${FULL_IMAGE}:${VARIANT}" "${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

echo "Successfully built ${VARIANT} variant with tags:"
echo "  - ${FULL_IMAGE}:${VARIANT}"
echo "  - ${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

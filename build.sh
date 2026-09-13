#!/bin/bash

set -ouex pipefail

# Input validation
VARIANT=${1:?VARIANT required (base|desktop|laptop)}
IMAGE_NAME=${2:?IMAGE_NAME required}
IMAGE_REGISTRY=${3:?IMAGE_REGISTRY required}
CACHE_PUSH=${4:?CACHE_PUSH required (true|false)}

FULL_IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}"
CACHE_REPO="${FULL_IMAGE}-cache-${VARIANT}"
TIMESTAMP=$(date -u +%Y%m%d)

echo "$(buildah --version)"

# Pin a chunkah release for reproducible builds; bump deliberately.
# Check https://github.com/coreos/chunkah/releases for newer tags.
CHUNKAH_VERSION="v0.6.0"
CHUNKAH_SPLITTER_URL="https://github.com/coreos/chunkah/releases/download/${CHUNKAH_VERSION}/Containerfile.splitter"

UNCHUNKED_TAG="localhost/${IMAGE_NAME}-${VARIANT}-unchunked:latest"

echo "Building ${VARIANT} variant of ${FULL_IMAGE}"

BUILD_ARGS=(--layers --cache-from "${CACHE_REPO}")
if [[ "${CACHE_PUSH}" == "true" ]]; then
  BUILD_ARGS+=(--cache-to "${CACHE_REPO}")
fi

buildah build "${BUILD_ARGS[@]}" -f "Containerfile.${VARIANT}" -t "${UNCHUNKED_TAG}" .

CHUNKAH_CONFIG_STR=$(buildah inspect --type image "${UNCHUNKED_TAG}")

#    --skip-unused-stages=false   required by chunkah's splitter flow
#    --prune /sysroot/            strips the embedded OSTree repo,
#                                  turning this into a "plain" image
#                                  chunkah can split
#    --max-layers 128             bootable images are big; the
#                                  default of 64 is tuned for smaller
#                                  ones
#    --label ostree.commit-       drop now-stale OSTree labels
#    --label ostree.final-diffid- (containers.bootc=1 is preserved
#                                  since it comes through in
#                                  CHUNKAH_CONFIG_STR)
buildah build \
  --skip-unused-stages=false \
  --from "${UNCHUNKED_TAG}" \
  --build-arg CHUNKAH_CONFIG_STR="${CHUNKAH_CONFIG_STR}" \
  --build-arg CHUNKAH_ARGS="--prune /sysroot/ --max-layers 128 --label ostree.commit- --label ostree.final-diffid-" \
  -t "${FULL_IMAGE}:${VARIANT}" \
  -v "$(pwd):/run/src" --security-opt label=disable \
  "${CHUNKAH_SPLITTER_URL}"

buildah tag "${FULL_IMAGE}:${VARIANT}" "${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

# Clean up the intermediate unchunked image.
buildah rmi "${UNCHUNKED_TAG}" || true

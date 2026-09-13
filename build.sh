#!/bin/bash

set -ouex pipefail

# Input validation
VARIANT=${1:?VARIANT required (base|desktop|laptop)}
IMAGE_NAME=${2:?IMAGE_NAME required}
IMAGE_REGISTRY=${3:?IMAGE_REGISTRY required}

FULL_IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}"
TIMESTAMP=$(date -u +%Y%m%d)

# Pin a chunkah release for reproducible builds; bump deliberately.
# Check https://github.com/coreos/chunkah/releases for newer tags.
CHUNKAH_VERSION="v0.6.0"
CHUNKAH_SPLITTER_URL="https://github.com/coreos/chunkah/releases/download/${CHUNKAH_VERSION}/Containerfile.splitter"

UNCHUNKED_TAG="localhost/${IMAGE_NAME}-${VARIANT}-unchunked:latest"

echo "Building ${VARIANT} variant of ${FULL_IMAGE}"

# 1. Build exactly as before, but into a throwaway local tag. This has
#    normal Dockerfile-shaped layers (one per RUN/COPY).
buildah build -f "Containerfile.${VARIANT}" -t "${UNCHUNKED_TAG}" .

# 2. Capture the image's config/labels (incl. containers.bootc=1 and
#    versioning info) before chunkah rebuilds it - the splitter flow
#    below doesn't carry these over on its own.
CHUNKAH_CONFIG_STR=$(buildah inspect --type image "${UNCHUNKED_TAG}")

# 3. Rechunk into content-based layers.
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
  "${CHUNKAH_SPLITTER_URL}"

buildah tag "${FULL_IMAGE}:${VARIANT}" "${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

# Clean up the intermediate unchunked image.
buildah rmi "${UNCHUNKED_TAG}" || true

echo "Successfully built ${VARIANT} variant with tags:"
echo "  - ${FULL_IMAGE}:${VARIANT}"
echo "  - ${FULL_IMAGE}:${VARIANT}-${TIMESTAMP}"

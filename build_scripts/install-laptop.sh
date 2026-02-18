#!/bin/bash

set -ouex pipefail

export DRACUT_NO_XATTR=1

echo "::group:: Build Laptop - Swap to Surface kernel"
dnf config-manager addrepo --assumeyes --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo
dnf swap --assumeyes --allowerasing kernel-core kernel-surface
dnf swap --assumeyes --allowerasing libwacom libwacom-surface
dnf swap --assumeyes --allowerasing libwacom-data libwacom-surface-data
dnf install --assumeyes iptsd
dnf install --assumeyes surface-secureboot
echo "::endgroup::"

echo "::group:: Build Laptop - Regenerate initramfs"
KERNEL_VERSION="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-surface)"
dracut -vf "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img" "${KERNEL_VERSION}"
echo "::endgroup::"

unset KERNEL_VERSION
unset DRACUT_NO_XATTR


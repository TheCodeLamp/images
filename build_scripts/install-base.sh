#!/bin/bash

set -ouex pipefail

echo "::group:: Build Base - Misc Packages"
dnf install --assumeyes \
bat \
bees \
cronie \
fish \
fzf \
git \
helix \
ripgrep \
snapper \
unzip \
zip \
zoxide \

dnf group install --assumeyes container-management

dnf --repo=fury-carapace install --assumeyes carapace

systemctl enable crond
echo "::endgroup::"

# =================== RPMFUSION ====================

echo "::group:: Build Base - RPM Fusion"
dnf install --assumeyes "dnf5-command(config-manager)"

dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf install --assumeyes --allowerasing \
megatools \
ffmpeg \

# Enable only when needed for an install.
dnf config-manager setopt "rpmfusion*".enabled=0
echo "::endgroup::"

# ==================== MULLVAD =====================

echo "::group:: Build Base - Mullvad"
FILE="/tmp/mullvad.rpm"
curl -L -o $FILE https://mullvad.net/en/download/app/rpm/latest
mkdir -p '/var/opt/Mullvad VPN'
dnf install --assumeyes $FILE
rm $FILE
echo "::endgroup::"

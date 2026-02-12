#!/bin/bash

set -ouex pipefail

dnf install --assumeyes \
bat \
bees \
cronie \
fish \
fzf \
helix \
ripgrep \
snapper \
zoxide \
git \
zip \
unzip \

dnf group install --assumeyes container-management

systemctl enable crond

# =================== RPMFUSION ====================

dnf install --assumeyes "dnf5-command(config-manager)"

dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf install --assumeyes --allowerasing \
megatools \
ffmpeg \

# Enable only when needed for an install.
dnf config-manager setopt "rpmfusion*".enabled=0

# ==================== MULLVAD =====================

FILE="/tmp/mullvad.rpm"
curl -L -o $FILE https://mullvad.net/en/download/app/rpm/latest
dnf install --assumeyes $FILE
rm $FILE

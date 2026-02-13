#!/bin/bash

set -ouex pipefail

echo "::group:: Build Desktop - Misc Packages"
dnf install --assumeyes \
alacritty \
btrfs-assistant \
solaar \
wl-clipboard
echo "::endgroup::"

# ===================== GROUPS =====================

echo "::group:: Build Desktop - Groups"
dnf group install --assumeyes kde-desktop kde-apps
dnf group install --assumeyes --with-optional libreoffice
echo "::endgroup::"

# ==================== NONFREE =====================

echo "::group:: Build Desktop - Nonfree Packages"
dnf config-manager setopt "rpmfusion*".enabled=1

# Codecs
dnf install --assumeyes @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

dnf install --assumeyes --allowerasing \
megasync dolphin-megasync

dnf config-manager setopt "rpmfusion*".enabled=0
echo "::endgroup::"

# ===================== FONTS ======================

echo "::group:: Build Desktop - Fonts"
FILE="/tmp/RobotoMono.zip"
FONTS_FOLDER="/usr/share/fonts"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/RobotoMono.zip"

mkdir -p $FONTS_FOLDER
curl -L -o $FILE $URL
unzip -o -d $"$FONTS_FOLDER/RobotoMono" $FILE
rm $FILE

unset FILE
unset FONTS_FOLDER
unset URL
echo "::endgroup::"

# =================== LIBREWOLF ====================

echo "::group:: Build Desktop - Librewolf"
dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf install --assumeyes librewolf
rm /etc/yum.repos.d/librewolf.repo
echo "::endgroup::"


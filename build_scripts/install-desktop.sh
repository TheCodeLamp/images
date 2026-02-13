#!/bin/bash

set -ouex pipefail

dnf install --assumeyes \
alacritty \
btrfs-assistant \
solaar \
wl-clipboard \

# ===================== GROUPS =====================

dnf group install --assumeyes kde-desktop kde-apps
dnf group install --assumeyes --with-optionals libreoffice

# ==================== NONFREE =====================

dnf config-manager setopt "rpmfusion*".enabled=1

# Codecs
dnf install --assumeyes @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

dnf install --assumeyes --allowerasing \
megasync dolphin-megasync

dnf config-manager setopt "rpmfusion*".enabled=0

# ===================== FONTS ======================

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

# =================== LIBREWOLF ====================

dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf install --assumeyes librewolf
rm /etc/yum.repos.d/librewolf.repo


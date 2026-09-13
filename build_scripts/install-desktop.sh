#!/bin/bash

set -ouex pipefail

echo "::group:: Build Desktop - Misc Packages"
dnf install --assumeyes \
alacritty \
btrfs-assistant \
fira-code-fonts \
solaar \
wl-clipboard\

dnf install --repo=firefoxpwa --assumeyes firefoxpwa

dnf --assumeyes copr enable wezfurlong/wezterm-nightly
dnf --assumeyes install wezterm
dnf --assumeyes copr disable wezfurlong/wezterm-nightly
echo "::endgroup::"

# ==================== NONFREE =====================

echo "::group:: Build Desktop - Nonfree Packages"
dnf config-manager setopt "rpmfusion*".enabled=1

# Codecs
dnf install --assumeyes --allowerasing @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

dnf install --assumeyes --allowerasing \
megasync dolphin-megasync \
dxvk-native wine-dxvk \
gamescope \
mangohud \
protontricks \
steam \
wine \
winetricks \

dnf config-manager setopt "rpmfusion*".enabled=0
echo "::endgroup::"

# =================== LIBREWOLF ====================

echo "::group:: Build Desktop - Librewolf"
dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf install --assumeyes librewolf
rm /etc/yum.repos.d/librewolf.repo
echo "::endgroup::"


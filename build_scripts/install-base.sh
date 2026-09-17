#!/bin/bash

set -ouex pipefail

# =================== PROTONVPN ====================
echo "::group:: Build Base - pvpn - Proton VPN client"
TMP=$(mktemp -d)
PRE_WD=$(pwd)
cd $TMP
PVPN_VERSION="1.0.4"
for bin in pvpn pvpnd pvpnctl; do
    curl -fsSL -o "${bin}" "https://github.com/YourDoritos/pVPN/releases/download/v${PVPN_VERSION}/${bin}-linux-amd64"
    install -Dm755 "${bin}" "/usr/bin/${bin}"
done
cd "${PRE_WD}"
unset TMP
unset PRE_WD
echo "::endgroup::"


echo "::group:: Build Base - Misc Packages"
dnf install --assumeyes \
bat \
bees \
cronie \
fd-find \
fish \
fzf \
git \
gitui \
helix \
rbw \
ripgrep \
snapper \
tcpdump \
unzip \
yt-dlp yt-dlp-fish-completion \
zip \
zoxide \

dnf install --assumeyes \
"dnf5-command(config-manager)" \
"dnf5-command(copr)" \

dnf group install --assumeyes container-management

dnf --repo=fury-carapace install --assumeyes carapace-bin

# yazi - terminal file explorer
dnf --assumeyes copr enable lihaohong/yazi
dnf --assumeyes install yazi
dnf --assumeyes copr disable lihaohong/yazi

systemctl enable crond
echo "::endgroup::"

# =================== RPMFUSION ====================

echo "::group:: Build Base - RPM Fusion"
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
systemd-tmpfiles --create /usr/lib/tmpfiles.d/rpm-ostree-0-integration-opt-usrlocal.conf
cat > /usr/lib/tmpfiles.d/mullvad-opt-compat.conf <<'EOF'
L+ /var/opt/Mullvad\x20VPN - - - - /usr/lib/Mullvad\x20VPN
L+ /opt/Mullvad\x20VPN - - - - /usr/lib/Mullvad\x20VPN
EOF
mkdir -p "/usr/lib/Mullvad VPN"
systemd-tmpfiles --create /usr/lib/tmpfiles.d/mullvad-opt-compat.conf

dnf --enable-repo=mullvad-stable install --assumeyes mullvad-vpn
echo "::endgroup::"

# ====================== NIX =======================

echo "::group:: Build Base - Nix Package Manager"
dnf install --assumeyes nix
rm -rf /nix/*
cat > /usr/lib/tmpfiles.d/var-nix.conf <<'EOF'
d /var/nix 0755 root root -
EOF
cat > /usr/lib/systemd/system/nix.mount <<'EOF'
[Unit]
Description=Bind mount /var/nix to /nix for Nix store
Before=nix-daemon.service
RequiresMountsFor=/var/nix

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=multi-user.target
EOF
systemctl enable nix.mount
echo "::endgroup::"


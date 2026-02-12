#!/bin/bash

set -ouex pipefail

dnf install --assumeyes \
--setopt=install_weak_deps=False \
bat \
bees \
fish \
helix \
ripgrep \
snapper \
zoxide \

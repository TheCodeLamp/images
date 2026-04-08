#!/bin/bash

set -ouex pipefail

# Appears when installing cronie
rm -rf /var/spool
rm -rf /var/lib/geoclue

# Remove created mullvad folder
rm -rf '/var/opt/Mullvad VPN'

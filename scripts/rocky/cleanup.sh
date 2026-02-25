#!/bin/bash
# Clean up packages and cloud-init data before running virt-sysprep

set -euo pipefail

echo "Cleaning up the system image..."

# Remove unused packages and clean package cache
dnf autoremove -y
dnf clean all

# Clean up dnf cache
rm -rf /var/cache/dnf/*

# Clean up cloud-init configuration and data
cloud-init clean --logs --seed

# Clean up log files
find /var/log -type f -exec truncate -s 0 {} \;
rm -rf /var/log/journal/*

sync

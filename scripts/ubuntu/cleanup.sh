#!/bin/bash
# Clean up packages and cloud-init data before running virt-sysprep

set -euo pipefail

echo "Cleaning up the system image..."

# Remove unused packages and clean package cache
apt-get autoremove -y
apt-get clean

# Clean up apt cache
rm -rf /var/lib/apt/lists/*

# Clean up cloud-init configuration and data
cloud-init clean --logs --seed

sync

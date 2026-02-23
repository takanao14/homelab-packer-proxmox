#!/bin/bash
# Cleanup script for Packer image preparation
# This script removes unnecessary packages, cache, logs, and user data
# to reduce the final image size and prepare it for cloning

set -euo pipefail

echo "Cleaning up the system image..."

# Remove unused packages and clean package cache
apt-get autoremove -y
apt-get clean

# Clean up apt cache and logs to reduce image size
rm -rf /var/lib/apt/lists/*
find /var/log -type f -exec truncate -s 0 {} \;

# Clean up cloud-init configuration and data
# This ensures fresh cloud-init runs on cloned instances
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
cloud-init clean --logs --seed

# Clean up machine-id and zero out free space
# machine-id will be regenerated on first boot
# Zero-fill free space to improve compression
truncate -s 0 /etc/machine-id
dd if=/dev/zero of=/zero_file bs=1M || true
sync
rm /zero_file
sync

# Remove the default ubuntu user created during installation
userdel -r -f ubuntu

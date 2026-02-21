#!/bin/bash
# Cleanup script for Packer image preparation
# This script removes unnecessary packages, cache, logs, and user data
# to reduce the final image size and prepare it for cloning

set -euo pipefail

echo "Cleaning up the system image..."

# Remove unused packages and clean package cache
dnf autoremove -y
dnf clean all

# Clean up cache and logs to reduce image size
rm -rf /var/cache/dnf/*
find /var/log -type f -exec truncate -s 0 {} \;

rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean up cloud-init configuration and data
# This ensures fresh cloud-init runs on cloned instances
rm -f /etc/cloud/cloud.cfg.d/99-disable-networking-activation.cfg
cloud-init clean --logs --seed

# Clean up machine-id and zero out free space
# machine-id will be regenerated on first boot
# Zero-fill free space to improve compression
truncate -s 0 /etc/machine-id
if [ -f /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
    ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

rm -f /etc/ssh/ssh_host_*

rm -f $HOME/.bash_history
history -c


dd if=/dev/zero of=/zero_file bs=1M || true
sync
rm /zero_file
sync

# Remove the default rocky user created during installation
userdel -r -f rocky


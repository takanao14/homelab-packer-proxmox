#!/bin/bash
# Cleanup script for Packer image preparation
# This script is intended to be run inside the VM image during the Packer build process.

set -euo pipefail

echo "Cleaning up the system image..."

# Remove unused packages and clean package cache
apt-get autoremove -y
apt-get clean

# Clean up apt cache
rm -rf /var/lib/apt/lists/*

# Clean up cloud-init configuration and data
cloud-init clean --logs --seed

# Remove the default ubuntu user created during installation
# userdel -r -f ubuntu

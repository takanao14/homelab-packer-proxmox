#!/bin/bash
# KVM and virtualization tools installation script
# Installs QEMU/KVM, libvirt, and associated utilities
# for virtual machine management and cloud image handling

set -euo pipefail

echo "Installing KVM/QEMU virtualization tools..."

# Update package lists
dnf update -y

# Install KVM/QEMU virtualization stack
# Includes hypervisor, management tools, and cloud-init utilities
dnf install -y \
    qemu-kvm \
    qemu-img \
    libvirt \
    libvirt-daemon \
    libvirt-daemon-kvm \
    libvirt-client \
    bridge-utils \
    virt-install \
    virt-manager \
    libvirt-devel \
    cloud-utils \
    genisoimage


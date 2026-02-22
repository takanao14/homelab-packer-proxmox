#!/bin/bash
# Container runtime installation script
# Installs Podman as a Docker-compatible container runtime

set -euo pipefail

echo "Installing Podman container runtime..."

# Update package lists
dnf update -y

# Install Podman and Docker compatibility layer
# podman-docker provides docker command aliases for Podman
dnf install -y podman podman-docker

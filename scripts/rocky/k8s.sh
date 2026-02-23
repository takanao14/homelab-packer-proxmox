#!/bin/bash
# Kubernetes tools installation script
# Installs kubectl, kubie, k9s, Helm, helmfile, and k0sctl
# These tools are essential for Kubernetes cluster management and operations

set -euo pipefail

echo "Installing Kubernetes tools..."

# Update package lists
dnf update -y

# Version pinning for reproducible builds
# These can be overridden via environment variables
KUBIE_VERSION="${KUBIE_VERSION:-v0.26.1}"
K9S_VERSION="${K9S_VERSION:-v0.50.18}"
HELMFILE_VERSION="${HELMFILE_VERSION:-1.3.0}"
K0SCTL_VERSION="${K0SCTL_VERSION:-v0.28.0}"

# Install kubectl from official Kubernetes repository
# Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

# Install required dependencies
dnf install -y curl gnupg

# Set up Kubernetes RPM repository
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF

# Update package lists and install kubectl
dnf update -y
dnf install -y kubectl

# Install Helm - Kubernetes package manager
# Reference: https://helm.sh/docs/intro/install/
dnf install -y helm

# Install kubie - Kubernetes context and namespace switcher
echo "Installing kubie ${KUBIE_VERSION}..."
curl -fsSL "https://github.com/sbstp/kubie/releases/download/${KUBIE_VERSION}/kubie-linux-amd64" -o /usr/local/bin/kubie
chmod 0755 /usr/local/bin/kubie

# Install k9s - Terminal-based UI for Kubernetes clusters
echo "Installing k9s ${K9S_VERSION}..."
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o "${TMP_DIR}/k9s.tar.gz"
tar -xzf "${TMP_DIR}/k9s.tar.gz" -C "${TMP_DIR}" k9s
install -m 0755 "${TMP_DIR}/k9s" /usr/local/bin/k9s
rm -rf "${TMP_DIR}"

# Install helmfile - Declarative Helm chart deployment tool
echo "Installing helmfile v${HELMFILE_VERSION}..."
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz" -o "${TMP_DIR}/helmfile.tar.gz"
tar -xzf "${TMP_DIR}/helmfile.tar.gz" -C "${TMP_DIR}" helmfile
install -m 0755 "${TMP_DIR}/helmfile" /usr/local/bin/helmfile
rm -rf "${TMP_DIR}"

# Install k0sctl - k0s cluster lifecycle management tool
echo "Installing k0sctl ${K0SCTL_VERSION}..."
curl -fSL "https://github.com/k0sproject/k0sctl/releases/download/${K0SCTL_VERSION}/k0sctl-linux-amd64" -o /usr/local/bin/k0sctl
chmod 0755 /usr/local/bin/k0sctl

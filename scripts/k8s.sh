#!/bin/bash
# Kubernetes tools installation script
# Installs kubectl, kubie, k9s, Helm, helmfile, and k0sctl
# These tools are essential for Kubernetes cluster management and operations

set -euo pipefail

echo "Installing Kubernetes tools..."

# Update package lists
apt-get update

# Version pinning for reproducible builds
# These can be overridden via environment variables
KUBIE_VERSION="${KUBIE_VERSION:-v0.26.1}"
K9S_VERSION="${K9S_VERSION:-v0.50.18}"
HELMFILE_VERSION="${HELMFILE_VERSION:-1.3.0}"
K0SCTL_VERSION="${K0SCTL_VERSION:-v0.28.0}"

# Install kubectl from official Kubernetes repository
# Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

# Install required dependencies for APT repository management
apt-get install -y apt-transport-https ca-certificates curl gnupg
# Set up Kubernetes APT repository
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Update package lists and install kubectl
apt-get update
apt-get install -y kubectl

# Install Helm - Kubernetes package manager
# Reference: https://helm.sh/docs/intro/install/
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

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

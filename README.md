# Homelab Cloud Images for Proxmox VE

> [!NOTE]
> **This repository has been merged into the `homelab` repository.**
> Maintenance and the latest configuration now live in the `homelab` repository. This repository is archived (read-only); please make any new changes in `homelab` instead.

This repository provides Packer templates and Terragrunt configurations to build and deploy cloud-init enabled VM images for Proxmox VE homelab infrastructure.

## Project Overview

- **Purpose**: Automated creation of cloud-init enabled golden images
- **Target Platform**: Proxmox VE
- **Supported OS**: Ubuntu 24.04, Rocky Linux 9/10, Debian 13
- **Image Variants**: Base (minimal) and XRDP (desktop environment with remote access)

## Requirements

### Build Requirements
- Packer >= 1.15.0
- QEMU tools (`qemu-img`)
- Proxmox VE API access
- Internet access for downloading base images and packages

### Deployment Requirements
- Terraform >= 1.6.0
- Terragrunt >= 0.99.4
- Proxmox VE cluster with API access

## Directory Structure

```
.
├── cinit/              # Cloud-init configuration templates for Packer
├── images/             # Generated image output directory (*.img files)
├── output-*/           # Packer build artifacts (temporary, gitignored)
├── scripts/
│   ├── ubuntu/         # Shell provisioners for Ubuntu
│   ├── rocky/          # Shell provisioners for Rocky Linux
│   └── debian/         # Shell provisioners for Debian
├── tf-cloudimage/      # Terragrunt configurations for image deployment
│   ├── dev/            # Development environment image configs
│   ├── node2/          # Node2 environment image configs
│   ├── node3/          # Node3 environment image configs
│   ├── prd/            # Production environment image configs
│   └── modules/        # Shared Terraform modules
├── renovate.json       # Renovate dependency update configuration
├── build.sh            # Main build script
└── *.pkr.hcl           # Packer template files
```

## Quick Start

### 1. Set Environment Variables

```bash
# Required: Set the default user password for cloud-init
export PKR_VAR_user_password='your_secure_password'

# Optional: Proxmox credentials for Terragrunt deployment
export PROXMOX_API_TOKEN=apiuser@pve!provider=...
export PROXMOX_ENDPOINT=https://...
export PROXMOX_VE_SSH_USERNAME='proxmox_user'
export PROXMOX_VE_SSH_AGENT=true
```

### 2. Build Images

```bash
# Build base Ubuntu 24.04 image with QEMU Guest Agent
./build.sh ubuntu24

# Build Ubuntu 24.04 with XRDP and XFCE desktop
./build.sh ubuntu24-xrdp

# Build base Rocky Linux 10 image
./build.sh rocky10

# Build Rocky Linux 9 with XRDP and XFCE desktop
./build.sh rocky9-xrdp

# Build base Debian 13 image
./build.sh debian13
```

### 3. Deploy Images to Proxmox (Optional)

```bash
cd tf-cloudimage/prd
terragrunt apply
```

## Available Packer Templates

| Template | Description | Output |
|----------|-------------|--------|
| [ubuntu-24.04-custom.pkr.hcl](ubuntu-24.04-custom.pkr.hcl) | Ubuntu 24.04 base with QEMU Guest Agent | `images/ubuntu-24.04-custom.img` |
| [ubuntu-24.04-xrdp.pkr.hcl](ubuntu-24.04-xrdp.pkr.hcl) | Ubuntu 24.04 with XRDP + XFCE4 desktop | `images/ubuntu-24.04-xrdp.img` |
| [rocky-10-custom.pkr.hcl](rocky-10-custom.pkr.hcl) | Rocky Linux 10 base image | `images/rocky-10-custom.img` |
| [rocky-9-xrdp.pkr.hcl](rocky-9-xrdp.pkr.hcl) | Rocky Linux 9 with XRDP + XFCE desktop | `images/rocky-9-xrdp.img` |
| [debian-13-custom.pkr.hcl](debian-13-custom.pkr.hcl) | Debian 13 base image | `images/debian-13-custom.img` |

## Build Script Options

The `build.sh` script simplifies the build process:

```bash
./build.sh [OPTIONS] <IMAGE_TYPE>
```

**Options:**
- `-y` - Force overwrite existing images without prompting

**Available IMAGE_TYPE values:**
- `ubuntu24` - Ubuntu 24.04 base image
- `ubuntu24-xrdp` - Ubuntu 24.04 with XRDP
- `rocky10` - Rocky Linux 10 base image
- `rocky9-xrdp` - Rocky Linux 9 with XRDP
- `debian13` - Debian 13 base image

### Build Process

1. Checks if the output image already exists and prompts for confirmation
2. Removes the corresponding `output-*` directory if it exists
3. Runs Packer build with appropriate variables
4. Converts the output to compressed qcow2 format in the `images/` directory

### Build Output

**Intermediate files (temporary):**
- `output-ubuntu24-custom/`
- `output-ubuntu24-xrdp/`
- `output-rocky-10-custom/`
- `output-rocky-9-xrdp/`
- `output-debian-13-custom/`

**Final images:**
- `images/ubuntu-24.04-custom.img`
- `images/ubuntu-24.04-xrdp.img`
- `images/rocky-10-custom.img`
- `images/rocky-9-xrdp.img`
- `images/debian-13-custom.img`

## Image Deployment with Terragrunt

After building images, deploy them to Proxmox VE using Terragrunt:

```bash
# Deploy to production environment
cd tf-cloudimage/prd
terragrunt apply

# Deploy to development environment
cd tf-cloudimage/dev
terragrunt apply
```

### Terragrunt Configuration Structure

Each environment directory contains:
- `terragrunt.hcl` - Environment-specific configuration

The shared modules in `tf-cloudimage/modules/` handle:
- Image upload to Proxmox datastore
- Content type configuration
- Storage management

## Dependency Management

This repository uses [Renovate](https://docs.renovatebot.com/) to automatically track and update dependency versions. See [renovate.json](renovate.json) for configuration.

**Tracked dependencies:**
- Kubernetes minor version in `scripts/*/k8s.sh` repository URLs (via `github-tags`)

**Not tracked (always installed as latest):**
- APT/DNF packages (kubectl, helm, terraform, packer, vault, VS Code, etc.)

## Customization

### Manual Packer Build

Run Packer directly for custom configurations:

```bash
packer build \
  -var "output_directory=custom-output" \
  -var "vm_name=custom.qcow2" \
  -var "image_name=image/custom.img" \
  ubuntu-24.04-custom.pkr.hcl
```

### Modifying Provisioning Scripts

Edit scripts in the `scripts/` directory:
- `scripts/ubuntu/` - Ubuntu-specific provisioners
- `scripts/rocky/` - Rocky Linux-specific provisioners
- `scripts/debian/` - Debian-specific provisioners

All scripts should be:
- Idempotent
- Follow bash best practices (`set -euo pipefail`)

### Cloud-init Configuration

Modify templates in `cinit/` directory to customize:
- Network configuration
- SSH key injection
- Package installation
- User creation

## Features

### Base Images
- ✅ Cloud-init enabled
- ✅ QEMU Guest Agent installed
- ✅ Minimal package set
- ✅ SSH key authentication only (password auth disabled)
- ✅ Optimized for cloning

### XRDP Images
All base features plus:
- ✅ XFCE4 desktop environment
- ✅ XRDP remote desktop server
- ✅ Pre-configured for remote access

## Security Considerations

- **SSH Authentication**: Password authentication is disabled; SSH key-only access
- **Default User**: Created via cloud-init with configurable password
- **Minimal Surface**: Only necessary packages are installed
- **Regular Updates**: Rebuild images regularly to include security patches
- **No Hardcoded Secrets**: All sensitive data passed via environment variables

## Troubleshooting

### Build Fails with "Permission Denied"
Ensure the Packer user has sudo access in the base cloud image.

### Image Already Exists
The build script will prompt you to confirm overwriting. Answer 'y' to proceed, or use `-y` flag to skip the prompt.

### Packer Cannot Connect to VM
Check that:
- QEMU is properly installed
- KVM is available (`/dev/kvm` exists)
- No firewall blocking SSH on port 22

### Terragrunt Apply Fails
Verify:
- Proxmox credentials are set correctly
- API endpoint is accessible
- Target node and datastore exist

## License

MIT License. See [LICENSE](LICENSE).

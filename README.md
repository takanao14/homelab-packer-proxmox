# Homelab Cloud Images for Proxmox VE

This repository provides Packer templates and Terragrunt configurations to build and deploy cloud-init enabled VM images for Proxmox VE homelab infrastructure.

## Project Overview

- **Purpose**: Automated creation of cloud-init enabled golden images
- **Target Platform**: Proxmox VE
- **Supported OS**: Ubuntu 24.04, Rocky Linux 9/10
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
│   └── rocky/          # Shell provisioners for Rocky Linux
├── tf-cloudimage/      # Terragrunt configurations for image deployment
│   ├── dev-*/          # Development environment image configs
│   ├── homelab/        # Production homelab image configs
│   └── modules/        # Shared Terraform modules
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
./build.sh ubuntu

# Build Ubuntu 24.04 with XRDP and XFCE desktop
./build.sh ubuntu-xrdp

# Build base Rocky Linux 10 image
./build.sh rocky

# Build Rocky Linux 9 with XRDP and XFCE desktop
./build.sh rocky-xrdp
```

### 3. Deploy Images to Proxmox (Optional)

```bash
cd tf-cloudimage/homelab
terragrunt apply
```

## Available Packer Templates

| Template | Description | Output |
|----------|-------------|--------|
| [ubuntu-24.04-custom.pkr.hcl](ubuntu-24.04-custom.pkr.hcl) | Ubuntu 24.04 base with QEMU Guest Agent | `images/ubuntu-24.04-custom.img` |
| [ubuntu-24.04-xrdp.pkr.hcl](ubuntu-24.04-xrdp.pkr.hcl) | Ubuntu 24.04 with XRDP + XFCE4 desktop | `images/ubuntu-24.04-xrdp.img` |
| [rocky-10-custom.pkr.hcl](rocky-10-custom.pkr.hcl) | Rocky Linux 10 base image | `images/rocky-10-custom.img` |
| [rocky-9-xrdp.pkr.hcl](rocky-9-xrdp.pkr.hcl) | Rocky Linux 9 with XRDP + XFCE desktop | `images/rocky-9-xrdp.img` |

## Build Script Options

The `build.sh` script simplifies the build process:

```bash
./build.sh <IMAGE_TYPE>
```

**Available IMAGE_TYPE values:**
- `ubuntu` - Ubuntu 24.04 base image
- `ubuntu-xrdp` - Ubuntu 24.04 with XRDP
- `rocky` - Rocky Linux 10 base image
- `rocky-xrdp` - Rocky Linux 9 with XRDP

### Build Process

1. Checks if the output image already exists and prompts for confirmation
2. Removes the corresponding `output-*` directory if it exists
3. Runs Packer build with appropriate variables
4. Converts the output to compressed qcow2 format in the `images/` directory

### Build Output

**Intermediate files (temporary):**
- `output-ubuntu-custom/`
- `output-ubuntu-xrdp/`
- `output-rocky-10-custom/`
- `output-rocky-9-xrdp/`

**Final images:**
- `images/ubuntu-24.04-custom.img`
- `images/ubuntu-24.04-xrdp.img`
- `images/rocky-10-custom.img`
- `images/rocky-9-xrdp.img`

## Image Deployment with Terragrunt

After building images, deploy them to Proxmox VE using Terragrunt:

```bash
# Deploy to homelab environment
cd tf-cloudimage/homelab
terragrunt apply

# Deploy to development environment
cd tf-cloudimage/dev-ubuntu-xrdp
terragrunt apply
```

### Terragrunt Configuration Structure

Each environment directory contains:
- `terragrunt.hcl` - Environment-specific configuration
- `.envrc` - Environment variables (using direnv)

The shared modules in `tf-cloudimage/modules/` handle:
- Image upload to Proxmox datastore
- Content type configuration
- Storage management

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

All scripts should be:
- Idempotent
- Well-documented with comments
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
- ✅ Japanese language support (optional)

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
The build script will prompt you to confirm overwriting. Answer 'y' to proceed.

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

#!/bin/bash
# Packer build script for creating VM images
# Usage: ./build.sh [ubuntu|ubuntu-xrdp|rocky]

set -euo pipefail

# Function to display usage information
usage() {
    cat << EOF
Usage: $0 [OPTION]

Build VM images using Packer

OPTIONS:
    ubuntu         Build basic Ubuntu 24.04 image with QEMU Guest Agent
    ubuntu-xrdp    Build Ubuntu 24.04 image with XRDP desktop environment
    rocky-xrdp     Build Rocky Linux image with XRDP (not yet implemented)
    help           Display this help message

EXAMPLES:
    $0 ubuntu
    $0 ubuntu-xrdp

EOF
    exit 1
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No build target specified"
    echo ""
    usage
fi

BUILD_TARGET="$1"

# Ensure images directory exists
mkdir -p images

# Function to check if destination file exists and prompt for overwrite
check_overwrite() {
    local dest_file="$1"
    local output_dir="$2"
    if [ -f "$dest_file" ]; then
        echo "Warning: Destination file '$dest_file' already exists"
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Build cancelled by user"
            exit 0
        fi
        rm -rf "$dest_file"
        rm -rf "$output_dir"
    fi
}

# Function to build and compress VM image
# Arguments: packer_file, packer_output_dir, packer_vm_name, dest_file, description
build_image() {
    local packer_file="$1"
    local packer_output_dir="$2"
    local packer_vm_name="$3"
    local dest_file="$4"
    local description="$5"

    check_overwrite "$dest_file" "$packer_output_dir"

    echo "Building ${description}..."
    packer build \
        -var "output_directory=${packer_output_dir}" \
        -var "vm_name=${packer_vm_name}" \
        "$packer_file"

    if [ ! -f "$packer_output_dir/$packer_vm_name" ]; then
        echo "Error: Source file '$packer_output_dir/$packer_vm_name' not found after build"
        exit 1
    fi

    echo "Compressing image..."
    qemu-img convert -O qcow2 -c "$packer_output_dir/$packer_vm_name" "$dest_file"
    echo "Output: $dest_file"
}

case "$BUILD_TARGET" in
    ubuntu)
        build_image \
            "ubuntu-24.04-qemu-ga.pkr.hcl" \
            "output-ubuntu-custom" \
            "ubuntu-24.04-custom.qcow2" \
            "images/ubuntu-24.04-custom.img" \
            "Ubuntu 24.04 base image with QEMU Guest Agent"
        ;;
    ubuntu-xrdp)
        build_image \
            "ubuntu-24.04-xrdp.pkr.hcl" \
            "output-ubuntu-xrdp" \
            "ubuntu-24.04-xrdp.qcow2" \
            "images/ubuntu-24.04-xrdp.img" \
            "Ubuntu 24.04 with XRDP"
        ;;
    rocky-xrdp)
        build_image \
            "rocky-10-xrdp.hcl" \
            "output-rocky-xrdp" \
            "rocky-10-xrdp.qcow2" \
            "images/rocky-10-xrdp.img" \
            "Rocky Linux 10 with XRDP"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown build target '$BUILD_TARGET'"
        echo ""
        usage
        ;;
esac

echo ""
echo "Build completed successfully!"

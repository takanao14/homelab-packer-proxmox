#!/bin/bash
set -euo pipefail

# Print help and exit with non-zero status.
usage() {
    cat << EOF
Usage: $0 [OPTION]

Build VM images using Packer

OPTIONS:
    ubuntu         Build a basic Ubuntu 24.04 image with the QEMU Guest Agent and the timezone set to JST
    ubuntu-xrdp    Build Ubuntu 24.04 image with XRDP desktop environment
    rocky10        Build a basic Rocky 10 Linux image with the timezone set to JST
    rocky-xrdp     Build Rocky Linux image with XRDP (not yet implemented)
    help           Display this help message

EXAMPLES:
    $0 ubuntu
    $0 ubuntu-xrdp

EOF
    exit 1
}

if [ $# -eq 0 ]; then
    echo "Error: No build target specified"
    usage
fi

BUILD_TARGET="$1"

mkdir -p images

# Confirm overwrite when output already exists.
check_overwrite() {
    local image_file="$1"
    local output_dir="$2"
    if [ -f "$image_file" ] || [ -d "$output_dir" ]; then
        echo "Warning: Destination file '$image_file' already exists"
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Build cancelled by user"
            exit 0
        fi
        rm -rf "$image_file"
        rm -rf "$output_dir"
    fi
}

# Run a Packer build for the given target.
# Arguments: packer_file, packer_output_dir, packer_vm_name, image_file
build_image() {
    local packer_file="$1"
    local packer_output_dir="$2"
    local packer_vm_name="$3"
    local image_file="$4"

    check_overwrite "$image_file" "$packer_output_dir"

    echo "Building ${packer_vm_name}..."
    packer build \
        -var "output_directory=${packer_output_dir}" \
        -var "vm_name=${packer_vm_name}" \
        -var "image_name=${image_file}" \
        "$packer_file"

    if [ ! -f "$packer_output_dir/$packer_vm_name" ]; then
        echo "Error: Source file '$packer_output_dir/$packer_vm_name' not found after build"
        exit 1
    fi
}

# Map CLI targets to their Packer templates and outputs.
case "$BUILD_TARGET" in
    ubuntu)
        build_image \
            "ubuntu-24.04-custom.pkr.hcl" \
            "output-ubuntu-custom" \
            "ubuntu-24.04-custom.qcow2" \
            "images/ubuntu-24.04-custom.img"
        ;;
    ubuntu-xrdp)
        build_image \
            "ubuntu-24.04-xrdp.pkr.hcl" \
            "output-ubuntu-xrdp" \
            "ubuntu-24.04-xrdp.qcow2" \
            "images/ubuntu-24.04-xrdp.img"
        ;;
    rocky10)
        build_image \
            "rocky-10-custom.pkr.hcl" \
            "output-rocky" \
            "rocky-10-custom.qcow2" \
            "images/rocky-10-custom.img"
        ;;
    rocky-xrdp)
        build_image \
            "rocky-9-xrdp.pkr.hcl" \
            "output-rocky-xrdp" \
            "rocky-9-xrdp.qcow2" \
            "images/rocky-9-xrdp.img"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown build target '$BUILD_TARGET'"
        usage
        ;;
esac

echo "Build completed successfully!"

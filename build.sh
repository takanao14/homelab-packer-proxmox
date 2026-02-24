#!/bin/bash
set -euo pipefail

# Print help and exit with non-zero status.
usage() {
    cat << EOF
Usage: $0 [OPTION]

Build VM images using Packer

OPTIONS:
    -y             Force overwrite existing images without prompting
    ubuntu         Build a basic Ubuntu 24.04 image with the QEMU Guest Agent and the timezone set to JST
    ubuntu-xrdp    Build Ubuntu 24.04 image with XRDP service
    rocky10        Build a basic Rocky 10 Linux image with the timezone set to JST
    rocky9-xrdp    Build Rocky Linux image with XRDP service
    help           Display this help message

EXAMPLES:
    $0 ubuntu
    $0 ubuntu-xrdp

EOF
    exit 1
}

FORCE_OVERWRITE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y)
            FORCE_OVERWRITE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option '$1'"
            usage
            ;;
        *)
            break
            ;;
    esac
done

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
        if [ "$FORCE_OVERWRITE" = false ]; then
            read -p "Do you want to overwrite it? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Build cancelled by user"
                exit 0
            fi
        fi
        rm -rf "$image_file"
        rm -rf "$output_dir"
    fi
}

# Run a Packer build for the given target.
# Arguments: packer_file, packer_output_dir, packer_vm_name, image_file
build_image() {
    local packer_file="$1"
    local packer_output="$2"
    local image_file="$3"

    local packer_output_dir=$(dirname "$packer_output")
    local packer_vm_name=$(basename "$packer_output")

    check_overwrite "$image_file" "$packer_output_dir"

    echo "Initializing Packer..."
    packer init "$packer_file"

    echo "Building ${packer_vm_name}..."
    packer build \
        -var "output_directory=${packer_output_dir}" \
        -var "vm_name=${packer_vm_name}" \
        -var "image_name=${image_file}" \
        "$packer_file"

    if [ ! -f "${packer_output}" ]; then
        echo "Error: Source file '${packer_output}' not found after build"
        exit 1
    fi

    if [ ! -f "${image_file}" ]; then
        echo "Error: Destination file '${image_file}' not found after build"
        exit 1
    fi
}

# Map CLI targets to their Packer templates and outputs.
case "$BUILD_TARGET" in
    ubuntu)
        build_image \
            "ubuntu-24.04-custom.pkr.hcl" \
            "output-ubuntu-custom/ubuntu-24.04-custom.qcow2" \
            "images/ubuntu-24.04-custom.img"
        ;;
    ubuntu-xrdp)
        build_image \
            "ubuntu-24.04-xrdp.pkr.hcl" \
            "output-ubuntu-xrdp/ubuntu-24.04-xrdp.qcow2" \
            "images/ubuntu-24.04-xrdp.img"
        ;;
    rocky)
        build_image \
            "rocky-10-custom.pkr.hcl" \
            "output-rocky-10-custom/rocky-10-custom.qcow2" \
            "images/rocky-10-custom.img"
        ;;
    rocky-xrdp)
        build_image \
            "rocky-9-xrdp.pkr.hcl" \
            "output-rocky-9-xrdp/rocky-9-xrdp.qcow2" \
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

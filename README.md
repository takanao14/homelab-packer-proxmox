## KVM Golden Image Builder

This repository provides Packer templates and helper scripts to build KVM-ready
golden images for Ubuntu and Rocky Linux. The main entry point is the build script.

## Requirements

- Packer installed and available on PATH
- QEMU tools installed (for `qemu-img`)
- KVM available on the host
- Internet access to fetch base cloud images and package repositories

## Packer Templates

- Ubuntu base image with QEMU Guest Agent: [ubuntu-24.04-custom.pkr.hcl](ubuntu-24.04-custom.pkr.hcl)
- Ubuntu XRDP image with XFCE: [ubuntu-24.04-xrdp.pkr.hcl](ubuntu-24.04-xrdp.pkr.hcl)
- Rocky base image: [rocky-10-custom.pkr.hcl](rocky-10-custom.pkr.hcl)
- Rocky XRDP image with XFCE: [rocky-9-xrdp.pkr.hcl](rocky-9-xrdp.pkr.hcl)

Both templates use variables for output configuration. The build script sets those variables for you.

## build.sh Usage

See the build script: [build.sh](build.sh)

Set the default user password via the `PKR_VAR_user_password` environment variable.
(eg. export PKR_VAR_user_password=mypassword)

```bash
./build.sh ubuntu
./build.sh ubuntu-xrdp
```

### Options

- `ubuntu`: build the base Ubuntu 24.04 image with QEMU Guest Agent
- `ubuntu-xrdp`: build the Ubuntu 24.04 image with XRDP + XFCE
- `rocky`: build the base Rocky 10 image
- `rocky-xrdp`: build the Rocky 9 image with XRDP + XFCE

### Output

Built images are written to the images directory with qcow2 compression:

- images/ubuntu-24.04-custom.img
- images/ubuntu-24.04-xrdp.img
- images/rocky-10-custom.img
- images/rocky-9-xrdp.img

During the build, Packer outputs intermediate files in:

- output-ubuntu-custom
- output-ubuntu-xrdp
- output-rocky-10-custom
- output-rocky-9-xrdp

If the destination image already exists, the script will prompt before
overwriting and will also remove the related output directory to avoid
conflicts.

## Customization

You can override output variables directly with Packer if you run templates
manually. Use a template file such as
[ubuntu-24.04-custom.pkr.hcl](ubuntu-24.04-custom.pkr.hcl), for example:

```bash
packer build \
	-var "output_directory=custom-output" \
	-var "vm_name=custom.qcow2" \
	TEMPLATE_FILE
```

## Notes

- Packer shell provisioners require sudo. Ensure the base image allows sudo for
	the configured user.
- The scripts in [scripts](scripts) install packages and perform cleanup tasks
	to prepare the image for cloning.

## License

MIT License. See [LICENSE](LICENSE).

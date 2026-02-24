packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# Variables for output configuration
variable "output_directory" {
  type        = string
  description = "Directory where the built image will be stored"
}

variable "vm_name" {
  type        = string
  description = "Name of the output VM image file"
}

variable "image_name" {
  type        = string
  description = "Name of the final image file after compression"
}

variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password for the default user account (used in Cloud-Init)"
}

# OS-specific locals - sysprep operations for Ubuntu
locals {
  ssh_pubkey = file("~/.ssh/id_ed25519.pub")
  sysprep_operations = join(",", [
    "user-account",
    "machine-id",
    "ssh-hostkeys",
    "ssh-userdir",
    "backup-files",
    "bash-history",
    "dhcp-client-state",
    "dhcp-server-state",
    "kerberos-data",
    "logfiles",
    "mail-spool",
    "net-hostname",
    "net-hwaddr",
    "pacct-log",
    "package-manager-cache",
    "passwd-backups",
    "tmp-files",
    "udev-persistent-net",
    "utmp",
    # "rpm-db",
    # "yum-uuid",
  ])
}

source "qemu" "ubuntu_xrdp" {
  # 公式イメージのURLとチェックサム
  iso_url      = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum = "file:https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
  disk_image   = true

  cpus      = 2
  memory    = 2048
  cpu_model = "host"

  # 出力設定
  output_directory = var.output_directory
  vm_name          = var.vm_name
  format           = "qcow2"
  disk_size        = "20G"
  accelerator      = "kvm"

  # SSH接続設定
  ssh_username   = "ubuntu"
  ssh_agent_auth = true
  ssh_timeout    = "15m"

  # Cloud-Init をシードディスクとして接続
  cd_content = {
    "/user-data" = templatefile("./cinit/ubuntu/user-data.pkrtpl.hcl", {
      ssh_pubkey    = local.ssh_pubkey
      user_password = var.user_password
    }),
    "/meta-data" = file("./cinit/ubuntu/meta-data")
  }
  cd_label = "cidata"
  # ヘッドレス（画面なし）で実行
  headless = true
}

build {
  sources = ["source.qemu.ubuntu_xrdp"]

  # パッケージのインストールとクリーンアップ
  provisioner "shell" {
    scripts = [
      "scripts/ubuntu/qemu-ga.sh",
      "scripts/ubuntu/xrdp.sh",
      "scripts/ubuntu/container.sh",
      "scripts/ubuntu/k8s.sh",
      "scripts/ubuntu/vm.sh",
      "scripts/ubuntu/tools.sh",
      "scripts/ubuntu/cleanup.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; sudo -S bash -c '{{ .Vars }} {{ .Path }}'"
  }

  post-processor "shell-local" {
    inline = [
      "virt-sysprep --remove-user-accounts ubuntu --operations ${local.sysprep_operations} -a ${var.output_directory}/${var.vm_name}",
      "virt-sparsify --compress ${var.output_directory}/${var.vm_name} ${var.image_name}",
    ]
  }
}

packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# Variables for output configuration
variable "output_directory" {
  type    = string
  default = "output-rocky-xrdp"
  description = "Directory where the built image will be stored"
}

variable "vm_name" {
  type    = string
  default = "rocky-10-xrdp.qcow2"
  description = "Name of the output VM image file"
}

source "qemu" "rocky_example" {
  # 公式イメージのURLとチェックサム
  iso_url            = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10-GenericCloud.qcow2"
  iso_checksum       = "file:https://download.rockylinux.org/pub/rocky/10/isos/x86_64/SHA256SUMS"
  disk_image         = true

  cpus = 2
  memory = 2048

  # 出力設定
  output_directory   = var.output_directory
  vm_name            = var.vm_name
  format             = "qcow2"
  disk_size          = "20G"
  accelerator        = "kvm"

  # SSH接続設定
  ssh_username       = "rocky"
  ssh_password       = "changeme"
  ssh_timeout        = "15m"

  # Cloud-Init をシードディスクとして接続
  cd_files = ["./rocky-data/user-data", "./rocky-data/meta-data"]
  cd_label = "cidata"

  # ヘッドレス（画面なし）で実行
  headless           = true
}

build {
  sources = ["source.qemu.ubuntu_example"]

  # パッケージのインストールとクリーンアップ
  provisioner "shell" {
    scripts = [
      "scripts/timezone.sh",
      "scripts/cleanup.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; sudo -S bash -c '{{ .Vars }} {{ .Path }}'"
  }
}

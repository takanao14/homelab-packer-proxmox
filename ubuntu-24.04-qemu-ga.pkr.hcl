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
  type    = string
  default = "output-ubuntu-custom"
  description = "Directory where the built image will be stored"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-24.04-custom.qcow2"
  description = "Name of the output VM image file"
}

source "qemu" "ubuntu_example" {
  # 公式イメージのURLとチェックサム
  iso_url            = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  iso_checksum       = "file:https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
  disk_image         = true

  cpus = 2
  memory = 2048
  
  # 出力設定
  output_directory   = var.output_directory
  vm_name            = var.vm_name
  format             = "qcow2"
  disk_size          = "10G"
  accelerator        = "kvm"
  
  # SSH接続設定
  ssh_username       = "ubuntu"
  ssh_password       = "changeme"
  ssh_timeout        = "15m"
  
  # Cloud-Init をシードディスクとして接続
  cd_files = ["./http/user-data", "./http/meta-data"]
  cd_label = "cidata"

  # ヘッドレス（画面なし）で実行
  headless           = true
}

build {
  sources = ["source.qemu.ubuntu_example"]

  # パッケージのインストールとクリーンアップ
  provisioner "shell" {
    scripts = [
      "scripts/qemu-ga.sh",
      "scripts/cleanup.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; sudo -S bash -c '{{ .Vars }} {{ .Path }}'"
  }
}

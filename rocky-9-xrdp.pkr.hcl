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
  default = "rocky-9-xrdp.qcow2"
  description = "Name of the output VM image file"
}

source "qemu" "rocky9-xrdp" {
  # 公式イメージのURLとチェックサム
  iso_url            = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  iso_checksum       = "file:https://download.rockylinux.org/pub/rocky/9/images/x86_64/CHECKSUM"
  disk_image         = true

  cpus = 2
  memory = 2048
  cpu_model = "host"

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
  cd_content = {
    "/user-data" = templatefile("./cinit/rocky/user-data.pkrtpl.hcl", {
      ssh_pubkey    = local.ssh_pubkey
      user_password = var.user_password
    }),
    "/meta-data" = file("./cinit/rocky/meta-data")
  }
  cd_label = "cidata"
  # ヘッドレス（画面なし）で実行
  headless           = false
}

build {
  sources = ["source.qemu.rocky9-xrdp"]

  # パッケージのインストールとクリーンアップ
  provisioner "shell" {
    scripts = [
      "rocky-scripts/timezone.sh",
      "rocky-scripts/cleanup.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; sudo -S bash -c '{{ .Vars }} {{ .Path }}'"
  }
}

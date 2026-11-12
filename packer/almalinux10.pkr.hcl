variable "almalinux_version" {
  type    = string
  default = "10.2"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "ssh_private_key_file" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

locals {
  iso_url = "https://repo.almalinux.org/almalinux/10/isos/x86_64/AlmaLinux-${var.almalinux_version}-x86_64-boot.iso"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://repo.almalinux.org/almalinux/10/isos/x86_64/CHECKSUM"
}

source "qemu" "almalinux10_x86_64" {
  qemu_binary      = "/usr/libexec/qemu-kvm"
  vm_name          = "packer_almalinux10_x86_64"
  output_directory = "../data/almalinux10_x86_64"
  accelerator      = "kvm"
  format           = "raw"
  headless         = true

  net_device       = "virtio-net"

  disk_interface   = "virtio"
  disk_size        = "5000M"
  disk_cache       = "none"
  disk_compression = true

  qemuargs = [
    ["-m", "2048M"], ["-smp", "2"], ["-cpu", "host"],
  ]

  iso_url      = "${local.iso_url}"
  iso_checksum = "${var.iso_checksum}"

  http_content = {
    "/almalinux10_ks.cfg" = templatefile(
      "${path.root}/almalinux10_ks.cfg.pkrtpl.hcl",
      {
        user = var.ssh_username
        ssh_public_key = var.ssh_public_key
      }
    )
  }

  boot_wait      = "5s"

  boot_command = [
    "e<down><down><end><bs><bs><bs><bs><bs>",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux10_ks.cfg ip=dhcp",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]

  ssh_username = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout  = "30m"

  shutdown_command = "sudo -S shutdown -P now"
}

build {
  sources = [
    "qemu.almalinux10_x86_64",
  ]

  provisioner "ansible" {
    playbook_file        = "./ansible/playbook.yml"
    galaxy_file          = "./ansible/requirements.yml"
    galaxy_force_install = true
    user                 = var.ssh_username
    use_sftp             = true
    ansible_env_vars     = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
  }
}
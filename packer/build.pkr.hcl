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

variable "iso_url" {
  type    = string
}

variable "iso_checksum" {
  type    = string
}

variable "base_os_url" {
  type = string
}

variable "app_stream_url" {
  type = string
}

variable "output_directory" {
  type = string
  default = "../data/output"
}

source "qemu" "qemu_raw_image" {
  qemu_binary      = "/usr/libexec/qemu-kvm"
  vm_name          = "packer_qemu"
  output_directory = "${var.output_directory}"
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

  iso_url      = "${var.iso_url}"
  iso_checksum = "${var.iso_checksum}"

  http_content = {
    "/ks.cfg" = templatefile(
      "${path.root}/ks.cfg.pkrtpl.hcl",
      {
        user = var.ssh_username
        ssh_public_key = var.ssh_public_key
        base_os_url = var.base_os_url
        app_stream_url = var.app_stream_url
      }
    )
  }

  boot_wait      = "5s"

  boot_command = [
    "e<down><down><end><bs><bs><bs><bs><bs>",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg ip=dhcp",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]

  ssh_username = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout  = "30m"

  shutdown_command = "sudo -S shutdown -P now"
}

build {
  sources = [
    "qemu.qemu_raw_image",
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
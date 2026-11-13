variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "ansible_ssh_private_key_file" {
  type      = string
  sensitive = true
}

variable "ansible_ssh_public_key" {
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

variable "qemu_binary" {
  type = string
}

variable "vm_name" {
  type = string
}

source "qemu" "qemu_raw_image" {
  qemu_binary      = var.qemu_binary
  vm_name          = var.vm_name
  output_directory = var.output_directory

  accelerator      = "kvm"
  format           = "raw"
  headless         = true
  
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  disk_size        = "3000M"
  disk_cache       = "none"
  disk_compression = true

  qemuargs = [
    ["-m", "2048M"], ["-smp", "2"], ["-cpu", "host"],
  ]

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  http_content = {
    "/ks.cfg" = templatefile(
      "${path.root}/ks.cfg.pkrtpl.hcl",
      {
        user = var.ssh_username
        ansible_ssh_public_key = var.ansible_ssh_public_key
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
  ssh_private_key_file = var.ansible_ssh_private_key_file
  ssh_timeout  = "30m"

  shutdown_command = "sudo -S shutdown -P now"
}

build {
  sources = [
    "qemu.qemu_raw_image",
  ]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/playbook.yml"
    galaxy_file   = "${path.root}/ansible/requirements.yml"

    galaxy_force_install = true

    user      = var.ssh_username
    use_proxy = true
    use_sftp  = true

    ansible_env_vars     = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]

    extra_arguments = [
      "--become",
      "--extra-vars",
      "ansible_python_interpreter=/usr/bin/python3",
    ]
  }
}
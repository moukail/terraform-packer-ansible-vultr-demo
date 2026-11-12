packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/ansible"
    }
    vultr = {
      source  = "github.com/vultr/vultr"
      version = ">= 2.3.2"
    }
  }
}
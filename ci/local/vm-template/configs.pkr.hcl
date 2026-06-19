packer {
  required_plugins {
    tart = {
      version = ">= 1.11.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

#[≟] derive from the base image baked by configs-base.pkr.hcl
variable "vm_base_name" {
  type    = string
  default = "configs-base"
}

variable "vm_name" {
  type    = string
  default = "configs"
}

variable "repo_path" {
  type    = string
  default = "/Users/ko/projects/configs"
}

#[≟] host-side git bundle (git bundle create configs.git.bundle --all) cloned into the vm — required
variable "bundle_path" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name = var.vm_base_name
  vm_name      = var.vm_name
  ssh_username = "admin"
  ssh_password = "admin"
  boot_wait    = "10s"
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "file" {
    source      = var.bundle_path
    destination = "/tmp/configs.git.bundle"
  }

  #[≟] git clone the bundle into the repo path as ko
  provisioner "shell" {
    inline = [
      "sudo install -d -o ko -g staff \"$(dirname '${var.repo_path}')\"",
      "sudo -u ko git clone /tmp/configs.git.bundle '${var.repo_path}'",
      "rm -f /tmp/configs.git.bundle",
    ]
  }
}

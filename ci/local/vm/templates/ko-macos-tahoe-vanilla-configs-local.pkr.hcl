packer {
  required_plugins {
    tart = {
      version = ">= 1.11.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

#[≟] derive from the base image baked by macos-tahoe-vanilla.pkr.hcl
variable "vm_base_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "repo_path" {
  type = string
}

#[≟] host-side git bundle (git bundle create configs.git.bundle --all) cloned into the vm — required
variable "bundle_path" {
  type = string
}

variable "pubkey_path" {
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
    source      = var.pubkey_path
    destination = "/tmp/authorized_key.pub"
  }

  provisioner "shell" {
    inline = [
      "sudo install -d -o ko -g staff -m 700 /Users/ko/.ssh",
      "sudo install -o ko -g staff -m 600 /tmp/authorized_key.pub /Users/ko/.ssh/authorized_keys",
    ]
  }

  provisioner "file" {
    source      = var.bundle_path
    destination = "/tmp/configs.git.bundle"
  }

  provisioner "shell" {
    inline = [
      "sudo install -d -o ko -g staff \"$(dirname '${var.repo_path}')\"",
      "sudo -u ko git clone /tmp/configs.git.bundle '${var.repo_path}'",
      "rm -f /tmp/configs.git.bundle",
    ]
  }
}

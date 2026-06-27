packer {
  required_plugins {
    tart = {
      version = ">= 1.11.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "vm_base_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "pubkey_path" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name       = var.vm_base_name
  vm_name            = var.vm_name
  cpu_count          = 4
  memory_gb          = 8
  disk_size_gb       = 100
  ssh_username       = "admin"
  ssh_password       = "admin"
  boot_wait          = "10s"
  recovery_partition = "delete"
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "file" {
    source      = var.pubkey_path
    destination = "/tmp/authorized_key.pub"
  }

  provisioner "shell" {
    inline = [
      "id ${var.username} >/dev/null 2>&1 || sudo sysadminctl -addUser ${var.username} -fullName ${var.username} -admin -adminUser admin -adminPassword admin",
      "sudo sysadminctl -resetPasswordFor ${var.username} -newPassword '${var.password}' -adminUser admin -adminPassword admin", #[what] ssh auth for gitlab-tart-executor (TART_EXECUTOR_SSH_USERNAME) 🤖🤖
      "echo '${var.username} ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/${var.username} >/dev/null",
      #[what] open remote login to all users #[why] avoid the com.apple.access_ssh group lockout
      "sudo install -d -o ${var.username} -g staff -m 700 /Users/${var.username}/.ssh",
      "sudo install -o ${var.username} -g staff -m 600 /tmp/authorized_key.pub /Users/${var.username}/.ssh/authorized_keys",
      "sudo dseditgroup -o edit -a ${var.username} -t user com.apple.access_ssh",
      "sudo dscacheutil -flushcache"
    ]
  }

  provisioner "shell" {
    inline = [
      "if ! xcode-select -p >/dev/null 2>&1; then sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; label=$(softwareupdate -l 2>/dev/null | grep -o 'Label: Command Line Tools.*' | tail -1 | sed 's/Label: //'); sudo softwareupdate -i \"$label\" --verbose; sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; fi",
    ]
  }
}

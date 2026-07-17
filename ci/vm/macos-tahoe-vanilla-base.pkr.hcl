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

variable "repo_path" {
  type = string
}

#[what] git bundle (git bundle create --all) cloned into vm. required 🤖
variable "bundle_path" {
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
      "sudo sysadminctl -resetPasswordFor ${var.username} -newPassword '${var.password}' -adminUser admin -adminPassword admin", #[why] ssh auth for gitlab-tart-executor (TART_EXECUTOR_SSH_USERNAME) 🤖🤖
      "echo '${var.username} ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/${var.username} >/dev/null",
      #[why] open remote login to all users, avoid com.apple.access_ssh group lockout
      "sudo install -d -o ${var.username} -g staff -m 700 /Users/${var.username}/.ssh",
      "sudo install -o ${var.username} -g staff -m 600 /tmp/authorized_key.pub /Users/${var.username}/.ssh/authorized_keys",
      "sudo dseditgroup -o edit -a ${var.username} -t user com.apple.access_ssh",
      "sudo dscacheutil -flushcache",
      #[why] ssh-forward the 1Password token + GCP SA key (virt-ssh-mac.zsh SendEnv) so `op` works in the vm and the restricted SA key becomes the vm's ADC identity (gcp:// secret resolution, mirrors the sandbox pod)
      "echo 'AcceptEnv OP_SERVICE_ACCOUNT_TOKEN GCP_SA_KEY' | sudo tee /etc/ssh/sshd_config.d/100-accept-op-token.conf >/dev/null"
    ]
  }

  provisioner "shell" {
    inline = [
      "if ! xcode-select -p >/dev/null 2>&1; then sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; label=$(softwareupdate -l 2>/dev/null | grep -o 'Label: Command Line Tools.*' | tail -1 | sed 's/Label: //'); sudo softwareupdate -i \"$label\" --verbose; sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress; fi",
    ]
  }

  ##[>] 🤖🤖
  provisioner "file" {
    source      = var.bundle_path
    destination = "/tmp/configs.git.bundle"
  }

  provisioner "shell" {
    inline = [
      "sudo install -d -o ${var.username} -g staff \"$(dirname '${var.repo_path}')\"",
      "sudo -u ${var.username} git clone /tmp/configs.git.bundle '${var.repo_path}'",
      "rm -f /tmp/configs.git.bundle",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo -iu ${var.username} make -C ${var.repo_path} repo-ci-install-deps",
      "sudo rm -rf '${var.repo_path}'",
    ]
  }
  ##[<] 🤖🤖
}

terraform {
  required_version = ">= 1.10"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.122.0" # any 0.122.x, so updates are patch fixes only
    }
  }
}

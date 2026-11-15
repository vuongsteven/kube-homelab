locals {
  # The host part of proxmox_endpoint, such as 192.168.1.10
  proxmox_host = regex("^https://([^:/]+)", var.proxmox_endpoint)[0]
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true # Proxmox uses a self-signed certificate

  # Snippets are uploaded over SSH, using the key loaded in ssh-agent
  ssh {
    agent    = true
    username = "root"

    node {
      name    = var.node_name
      address = local.proxmox_host
    }
  }
}

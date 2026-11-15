locals {
  # The address without its prefix length, such as 192.168.1.150
  ip = split("/", var.ip_address)[0]
}

# Ubuntu 24.04 cloud image, a ready-made disk that cloud-init sets up at first boot.
# A dated release keeps rebuilds identical, and the checksum proves the download is intact.
resource "proxmox_download_file" "ubuntu" {
  content_type       = "import"
  datastore_id       = "local"
  node_name          = var.node_name
  url                = "https://cloud-images.ubuntu.com/releases/noble/release-20261017/ubuntu-24.04-server-cloudimg-amd64.img"
  file_name          = "ubuntu-24.04-server-cloudimg-amd64-20261017.qcow2" # Proxmox needs the real format here
  checksum           = "04e8f2461a16a44e78a370284471f29616cdd9baf1893df25807b71f985b6c94"
  checksum_algorithm = "sha256"
}

# The cloud-init template, filled in and stored on Proxmox as a snippet
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    file_name = "${var.hostname}-user-data.yaml"
    data = templatefile("${path.module}/templates/user-data.yaml.tftpl", {
      hostname       = var.hostname
      timezone       = var.timezone
      username       = var.vm_user
      ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_file)))
    })
  }
}

resource "proxmox_virtual_environment_vm" "dev" {
  name        = var.hostname
  description = "Development VM for Claude Code. Managed by Terraform (kube-homelab)."
  tags        = ["dev", "terraform"]
  node_name   = var.node_name
  vm_id       = var.vm_id
  on_boot     = true

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.ubuntu.id
    interface    = "virtio0"
    size         = var.disk_gb
    discard      = "on"
  }

  network_device {
    bridge   = "vmbr0"
    firewall = true # apply this VM's firewall rules to this card
  }

  operating_system {
    type = "l26"
  }

  # cloud-init installs the agent, and Terraform waits for it to report in.
  # First boot installs a lot, so allow extra time.
  agent {
    enabled = true
    timeout = "20m"
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    dns {
      servers = ["1.1.1.1", "9.9.9.9"]
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
}

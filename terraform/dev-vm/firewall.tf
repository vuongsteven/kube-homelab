# The dev VM can reach the internet but not the home network.
# Proxmox enforces this outside the VM, so nothing inside it can turn it off.
resource "proxmox_virtual_environment_firewall_options" "dev" {
  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.dev.vm_id

  enabled       = true
  input_policy  = "DROP"   # block incoming traffic unless a rule allows it
  output_policy = "ACCEPT" # allow outgoing traffic unless a rule blocks it
  radv          = false    # the VM may not announce itself as a router
}

resource "proxmox_virtual_environment_firewall_rules" "dev" {
  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.dev.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "SSH from the home network"
    source  = var.home_network
    proto   = "tcp"
    dport   = "22"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Ping from the home network"
    source  = var.home_network
    macro   = "Ping"
  }

  rule {
    type    = "out"
    action  = "REJECT"
    comment = "No new connections to private networks, including home"
    dest    = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  }
}

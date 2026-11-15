variable "proxmox_endpoint" {
  description = "Proxmox web address, such as https://192.168.1.10:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token in the form terraform@pve!dev-vm=<secret>. Set it as an environment variable."
  type        = string
  sensitive   = true # hide it in Terraform's output
}

variable "node_name" {
  description = "Proxmox node name, as shown in the web interface's left tree"
  type        = string
  default     = "pve01"
}

variable "ip_address" {
  description = "The VM's fixed address with prefix length, such as 192.168.1.150/24"
  type        = string
}

variable "gateway" {
  description = "Your router's address"
  type        = string
}

variable "vm_user" {
  description = "The login user cloud-init creates on the VM"
  type        = string
  default     = "dev"
}

variable "ssh_public_key_file" {
  description = "Public key allowed to log in as vm_user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "hostname" {
  description = "The VM's name in Proxmox and its hostname"
  type        = string
  default     = "dev-vm"
}

variable "timezone" {
  description = "Time zone, such as America/Vancouver"
  type        = string
  default     = "Etc/UTC"
}

variable "vm_id" {
  description = "Proxmox VM ID"
  type        = number
  default     = 120
}

variable "cpu_cores" {
  type    = number
  default = 4
}

variable "memory_mb" {
  type    = number
  default = 6144
}

variable "disk_gb" {
  type    = number
  default = 64
}

variable "home_network" {
  description = "Your home network, allowed to SSH and ping the VM, such as 192.168.1.0/24"
  type        = string
}

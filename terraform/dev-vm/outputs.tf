output "ip_address" {
  description = "The VM's address"
  value       = local.ip
}

output "ssh_command" {
  description = "How to log in"
  value       = "ssh ${var.vm_user}@${local.ip}"
}

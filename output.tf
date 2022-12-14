/* output "app" {
  value = "http://${data.oci_core_vnic.app_vnic.public_ip_address}"
}

output "generated_private_key_pem" {
  value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
} */
output "vm1_public_ip" {
  value = module.prod-vm1-public_ip.public_ip_address
}
output "prod-db-endpoint" {
  value = module.azure-mysql-db.production-db-endpoint
}
output "azure-prod-db-username" {
  sensitive = true
  value = module.azure-mysql-db.db-username
}

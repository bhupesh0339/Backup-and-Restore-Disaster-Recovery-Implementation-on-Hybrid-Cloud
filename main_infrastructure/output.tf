output "cloudfalre-terraform-domain-name" {
  value = module.cloudflare_domain_terraform.domain_name
}
output "instance_public_ip" {
  value = module.prod_instance_1.instance_public_ip
}
output "rds_endpoint" {
  value = module.prod_rds_mysql.db_endpoint
}
output "sas-token" {
  value     = module.databackup1000_sas_token.sas_url_query_string
  sensitive = true
}
variable "aws-access-key" {}
variable "aws-secret-key" {}
variable "aws-region-main" {}
variable "cloudflare-api-token-value" {}
variable "cloudflare-zone-id" {}
variable "rds_prod_db_username" {
  sensitive = true
}
variable "rds_prod_db_password" {
  sensitive = true
}
variable "database_name" {
  sensitive = true
}
variable "certbot-ssl-email" {}
variable "git_repository_python_app" {}
variable "github_token" {}
variable "azure-uploadfile-account-username" {}
variable "azure-uploadfile-account-password" {}
variable "backup_storage_account_name" {}
variable "backup_container_name" {}
variable "azure_db_password" {}
variable "azure_db_username" {}
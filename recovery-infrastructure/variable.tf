####### Cloudflare
variable "cloudflare-zone-id" {}
variable "cloudflare-api-token-value" {}
variable "azure_db_password" {
  sensitive = true
}
variable "azure_db_username" {
  sensitive = true
}
variable "database_name" {
  sensitive = true
}
variable "certbot-ssl-email" {}
variable "git_repo_https_url" {}
variable "github_token" {}
variable "backup_storage_account_name" {}
variable "backup_container_name" {}
variable "git_repo_application_branch" {}
variable "domain_name" {}
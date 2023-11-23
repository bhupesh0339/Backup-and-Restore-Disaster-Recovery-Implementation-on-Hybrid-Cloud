terraform {
  required_version = "> 1.6.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region     = var.aws-region-main
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
provider "cloudflare" {
  api_token = var.cloudflare-api-token-value
}
module "azure_backup_resource_group" {
  source                          = "./azure/resource_group"
  azurerm_resource_group-name     = "databackup1000"
  azurerm_resource_group-location = "West Europe"
}
module "backup_storage_account" {
  source                                           = "./azure/storage_account"
  azurerm_storage_account_name                     = var.backup_storage_account_name
  azurerm_storage_account_account_tier             = "Standard"
  azurerm_storage_account_account_replication_type = "GRS"
  resource_group_name                              = module.azure_backup_resource_group.resource_group_name
  resource_group_location                          = module.azure_backup_resource_group.resource_group_location
}
module "azure_storage_container" {
  source                 = "./azure/storage_container"
  storage_container_name = var.backup_container_name
  storage_account_name   = module.backup_storage_account.storage_account_name
  container_access_type  = "private"
}
module "databackup1000_sas_token" {
  source                            = "./azure/SAS_token"
  storage_account_connection_string = module.backup_storage_account.primary_connection_string
}
module "prod_rds_mysql" {
  source             = "./aws/rds"
  storage_size       = [10]
  db_name            = var.database_name
  instance_class     = "db.t3.micro"
  db_username        = var.rds_prod_db_username
  Password           = var.rds_prod_db_password
  publicly_exposed   = "true"
  security_group_ids = [module.rds_security_group.security_group_id]
  depends_on         = [module.rds_security_group]
}
module "production_instance_1_keypair" {
  source         = "./aws/key_pair"
  key_pair_name  = "production_instance_1_keypair"
  public_ssh_key = file("~/.ssh/id_rsa.pub")
}
module "prod_instance_security_group" {
  source                    = "./aws/security_group"
  security_group_name       = "prod_instance_security_group"
  security_group_open_ports = [80, 443, 22]
}
module "cloudflare_domain_terraform" {
  source                  = "./cloudflare"
  cloudflare-zone-id      = var.cloudflare-zone-id
  cloudflare-domain-name  = "aws.testmyinfra.com"
  cloudflare-ipv4-address = module.prod_instance_1.instance_public_ip
  cloudflare-record-type  = "A"
  cloudflare-api-token    = var.cloudflare-api-token-value
}
module "rds_security_group" {
  source                    = "./aws/security_group"
  security_group_name       = "rds_public_security_group"
  security_group_open_ports = [3306]
}
module "prod_instance_1" {
  source                 = "./aws/instance"
  instance-type          = "t2.large"
  key_pair_name          = module.production_instance_1_keypair.keypair_name
  vpc_security_group_ids = [module.prod_instance_security_group.security_group_id]
  InstanceNameTag        = "Prod_Instance_1"
}
resource "null_resource" "configure_instance_2" {
  depends_on = [module.prod_instance_1]
  provisioner "local-exec" {
    command = <<-EOT
    sleep 2m
    ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no' -i '${module.prod_instance_1.instance_public_ip},' -e 'private_key=~/.ssh/id_rsa domain_name=${module.cloudflare_domain_terraform.domain_name} ssl_email=${var.certbot-ssl-email} gitrepo=${var.git_repository_python_app} git_token=${var.github_token} db_host=${module.prod_rds.db_endpoint} db_user=${var.rds_prod_db_username}  db_password=${var.rds_prod_db_password} azureStorageAccountName=${module.backup_storage_account.storage_account_name} db_database=${var.database_name} azureContainerName=${module.azure_storage_container.container_name} sas_token=${module.databackup1000_sas_token.sas_url_query_string} ' -u ubuntu ./ansible/playbook.yml -vvv
  EOT
  }
}
resource "null_resource" "send-sas-token-for-recovery" {
  depends_on = [module.databackup1000_sas_token]
  provisioner "local-exec" {
    command = "terraform output sas-token > ../Recovery-Infrastructure/sas_token"
  }
}
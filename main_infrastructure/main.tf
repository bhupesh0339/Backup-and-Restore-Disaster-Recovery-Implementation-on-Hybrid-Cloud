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
  source                          = "./modules/azure/resource_group"
  azurerm_resource_group-name     = "databackup1000"
  azurerm_resource_group-location = "West Europe"
}
module "backup_storage_account" {
  source                                           = "./modules/azure/storage_account"
  azurerm_storage_account_name                     = var.backup_storage_account_name
  azurerm_storage_account_account_tier             = "Standard"
  azurerm_storage_account_account_replication_type = "GRS"
  resource_group_name                              = module.azure_backup_resource_group.resource_group_name
  resource_group_location                          = module.azure_backup_resource_group.resource_group_location
}
module "azure_storage_container" {
  source                 = "./modules/azure/storage_container"
  storage_container_name = var.backup_container_name
  storage_account_name   = module.backup_storage_account.storage_account_name
  container_access_type  = "private"
}
module "databackup1000_sas_token" {
  source                            = "./modules/azure/SAS_token"
  storage_account_connection_string = module.backup_storage_account.primary_connection_string
}
module "prod_rds_mysql" {
  source             = "./modules/aws/rds"
  storage_size       = "10"
  db_name            = var.database_name
  instance_class     = "db.t3.micro"
  db_username        = var.rds_prod_db_username
  Password           = var.rds_prod_db_password
  publicly_exposed   = "true"
  security_group_ids = [module.rds_security_group.security_group_id]
  depends_on         = [module.rds_security_group]
}
module "production_instance_1_keypair" {
  source         = "./modules/aws/key_pair"
  key_pair_name  = "production_instance_1_keypair"
  public_ssh_key = file("~/.ssh/id_rsa.pub")
}
module "prod_instance_security_group" {
  source                    = "./modules/aws/security_group"
  security_group_name       = "prod_instance_security_group"
  security_group_open_ports = [80, 443, 22]
}
module "cloudflare_domain_terraform" {
  source                  = "./modules/cloudflare"
  cloudflare-zone-id      = var.cloudflare-zone-id
  cloudflare-domain-name  = var.domain_name
  cloudflare-ipv4-address = module.prod_instance_1.instance_public_ip
  cloudflare-record-type  = "A"
  cloudflare-api-token    = var.cloudflare-api-token-value
}
module "rds_security_group" {
  source                    = "./modules/aws/security_group"
  security_group_name       = "rds_public_security_group"
  security_group_open_ports = [3306]
}
module "prod_instance_1" {
  source                 = "./modules/aws/instance"
  instance-type          = "t2.large"
  key_pair_name          = module.production_instance_1_keypair.keypair_name
  vpc_security_group_ids = [module.prod_instance_security_group.security_group_id]
  InstanceNameTag        = "Prod_Instance_1"
}
resource "null_resource" "configure_instance_2" {
  depends_on = [module.prod_instance_1]
  provisioner "local-exec" {
    command = <<-EOT
    sleep 300 && ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no' -i '${module.prod_instance_1.instance_public_ip},' -e 'private_key=~/.ssh/id_rsa domain_name=${module.cloudflare_domain_terraform.domain_name} ssl_email=${var.certbot-ssl-email} gitrepo=${var.git_repo_https_url} git_branch=${var.git_repo_application_branch} git_token=${var.github_token} db_host=${module.prod_rds_mysql.db_endpoint} db_user=${var.rds_prod_db_username}  db_password=${var.rds_prod_db_password} azureStorageAccountName=${module.backup_storage_account.storage_account_name} db_database=${var.database_name} azureContainerName=${module.azure_storage_container.container_name} sas_token=${module.databackup1000_sas_token.sas_url_query_string} ' -u ubuntu ./ansible/playbook.yml -vvv
  EOT
  }
}
resource "null_resource" "send-sas-token-for-recovery" {
  depends_on = [module.databackup1000_sas_token]
  provisioner "local-exec" {
    command = "terraform output sas-token > ../recovery_infrastructure/sas_token"
  }
}
locals {
  db_endpoint_without_port = join(":", slice(split(":", module.prod_rds_mysql.db_endpoint), 0, 1))
}

resource "aws_lambda_function" "backup_mysql_lambda" {
  function_name    = "backup_mysql_dump"
  runtime          = "python3.9"
  handler = "lambda_function.lambda_handler"
  timeout = "30"
  filename         = "./dbdump_lambda_function/my-deployment-package.zip"
  role             = aws_iam_role.lambda_execution_role.arn
  environment {
    variables = {
      DB_HOST              = local.db_endpoint_without_port,
      DB_USER              = var.rds_prod_db_username,
      DB_PASSWORD          = var.rds_prod_db_password,
      DB_NAME              = var.database_name,
      azure_sas_token      = module.databackup1000_sas_token.sas_url_query_string,
      azureStorageAccountName = module.backup_storage_account.storage_account_name,
      azureContainerName   = module.azure_storage_container.container_name,
    }
  }
}
resource "aws_scheduler_schedule" "invoke_lambda" {
  name       = "create_dump_sch"
  group_name = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "cron(*/2 * * * ? *)"
  target {
    arn      = aws_lambda_function.backup_mysql_lambda.arn
    role_arn = aws_iam_role.lambda_invoke_schedular_role.arn
  }
depends_on = [ aws_lambda_function.backup_mysql_lambda ]
}
terraform {
  required_version = "> 1.6.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
module "azure_production_resource_group" {
  source                          = "./azure/resource-group"
  azurerm_resource_group-name     = "production_resource_group"
  azurerm_resource_group-location = "West Europe"
}
module "azure_production_virtual_network" {
  source                          = "./azure/virtual_network"
  azure-virtual-network-name      = "production-vn"
  azure-virtual-network-cidr      = "10.0.0.0/16"
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  depends_on                      = [module.azure_production_resource_group]
}
module "azure_production-subnet1" {
  source                      = "./azure/subnet"
  azure-subnet-name           = "azure-production-vn-subnet1"
  azure-subnet-cidr           = ["10.0.0.0/16"]
  azurerm_resource_group-name = module.azure_production_resource_group.resource_group_name
  virtual_network_name        = module.azure_production_virtual_network.virtual-network-name
  depends_on                  = [module.azure_production_resource_group, module.azure_production_virtual_network]
}
module "vm1_security_group" {
  source                          = "./azure/security_group"
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  security_group_name             = "prod_vm1_subnet"
  allowed_ports                   = [80, 22, 443]
  depends_on                      = [module.azure_production_resource_group]
}
module "prod-vm1-public_ip" {
  source                          = "./azure/public_ips"
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  public_ip_name                  = "prod_vm_ip1"
  depends_on                      = [module.azure_production_resource_group]
}
module "prod-vm1-nic" {
  source                          = "./azure/network_interface"
  nic-name                        = "prod_vm1.nic"
  public_ip_address               = module.prod-vm1-public_ip.public_ip_id
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  subnet_id                       = module.azure_production-subnet1.subnet-id
  depends_on                      = [module.azure_production_resource_group]
}
module "azure-mysql-db" {
  source                          = "./azure/azure_database_mysql"
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  production-mysql-db-name        = var.database_name
  azure-database-username         = var.azure_db_username
  azure-database-password         = var.azure_db_password
  database-server-size            = "B_Gen5_1"
  storage-size-MB                 = "5120"
  mysql-version                   = "5.7"
  depends_on                      = [module.azure_production_resource_group]
}
module "azure_prod_vm1" {
  source                          = "./azure/virtual_machine_linux"
  virtual_machine_name            = "Production-VM1"
  azurerm_resource_group-name     = module.azure_production_resource_group.resource_group_name
  azurerm_resource_group-location = module.azure_production_resource_group.resource_group_location
  vm_size                         = "Standard_F2"
  ssh_admin_user                  = "alpha"
  network_interface_card          = module.prod-vm1-nic.nic_id
  ssh_public_key                  = file("~/.ssh/id_rsa.pub")
  disk_storage_account_type       = "Standard_LRS"
  depends_on                      = [module.azure_production_resource_group]
}
module "cloudflare-domain" {
  source                  = "./cloudflare"
  cloudflare-zone-id      = var.cloudflare-zone-id
  cloudflare-domain-name  = "azure.testmyinfra.com"
  cloudflare-ipv4-address = module.azure_prod_vm1.vm_public_ip
  cloudflare-record-type  = "A"
  cloudflare-record-ttl   = "300"
  cloudflare-api-token    = var.cloudflare-api-token-value
}
locals {
  sas_token = file("./sas_token")
}
resource "null_resource" "setup_vm_prod" {
  depends_on = [module.azure_prod_vm1]
  provisioner "local-exec" {
    command = "ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no' -i '${module.azure_prod_vm1.vm_public_ip},' -e 'domain_name=${module.cloudflare-domain.domain_name} ssl_email=${var.certbot-ssl-email} gitrepo=${var.git_repository_python_app} git_token=${var.github_token} db_host=${module.azure-mysql-db.production-db-endpoint} db_user=${var.azure_db_username}  db_password=${var.azure_db_password} azureStorageAccountName=${var.backup_storage_account_name} db_database=${var.database_name} azureContainerName=${var.backup_container_name} sas_token=${local.sas_token} ' -u ${module.azure_prod_vm1.vm_username} ./ansible/playbook.yml -vvv"
  }
}
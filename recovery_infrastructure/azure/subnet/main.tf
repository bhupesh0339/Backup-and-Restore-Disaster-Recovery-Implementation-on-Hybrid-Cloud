resource "azurerm_subnet" "subnet" {
  name                 = var.azure-subnet-name
  resource_group_name  = var.azurerm_resource_group-name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.azure-subnet-cidr
}
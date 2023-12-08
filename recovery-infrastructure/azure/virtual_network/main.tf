resource "azurerm_virtual_network" "production-vn" {
  name                = var.azure-virtual-network-name
  address_space       = [var.azure-virtual-network-cidr]
  resource_group_name = var.azurerm_resource_group-name
  location            = var.azurerm_resource_group-location
}
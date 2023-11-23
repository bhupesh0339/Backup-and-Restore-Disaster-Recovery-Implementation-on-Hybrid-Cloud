resource "azurerm_resource_group" "resource-group" {
  name     = var.azurerm_resource_group-name
  location = var.azurerm_resource_group-location
}
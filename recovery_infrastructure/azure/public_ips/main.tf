resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.azurerm_resource_group-name
  location            = var.azurerm_resource_group-location
  allocation_method   = "Static"
  tags = {
    environment = "Production"
  }
}
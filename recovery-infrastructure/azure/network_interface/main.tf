resource "azurerm_network_interface" "nic" {
  name                = var.nic-name
  resource_group_name = var.azurerm_resource_group-name
  location            = var.azurerm_resource_group-location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_address
  }
}
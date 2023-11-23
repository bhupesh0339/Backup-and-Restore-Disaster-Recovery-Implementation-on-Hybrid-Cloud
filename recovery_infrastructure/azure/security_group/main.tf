
# resource "azurerm_network_security_group" "azure-vm-sg" {
#   name                = var.security_group_name
#   resource_group_name = var.azurerm_resource_group-name
#   location            = var.azurerm_resource_group-location
#   security_rule {
#     name                       = "HTTP"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1002
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   security_rule {
#     name                       = "HTTPS"
#     priority                   = 1003
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "443"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

resource "azurerm_network_security_group" "azure-vm-sg" {
  name                = var.security_group_name
  resource_group_name = var.azurerm_resource_group-name
  location            = var.azurerm_resource_group-location
  dynamic "security_rule" {
    for_each = var.allowed_ports
    content {
      name                       = "Port-${security_rule.value}"
      priority                   = 1000 + security_rule.value
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
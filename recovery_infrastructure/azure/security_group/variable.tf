variable "azurerm_resource_group-name" {}
variable "azurerm_resource_group-location" {}
variable "security_group_name" {}
variable "allowed_ports" {
  type = list(number)
}
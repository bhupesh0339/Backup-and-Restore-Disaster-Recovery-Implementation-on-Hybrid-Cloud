resource "azurerm_storage_account" "recovery-azure-storage-account" {
  name                     = var.azurerm_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = var.azurerm_storage_account_account_tier
  account_replication_type = var.azurerm_storage_account_account_replication_type
}

output "primary_connection_string" {
  value = azurerm_storage_account.recovery-azure-storage-account.primary_connection_string
}
output "storage_account_name" {
  value = azurerm_storage_account.recovery-azure-storage-account.name
}
resource "azurerm_mysql_server" "mysql_db" {
  name                              = var.production-mysql-db-name
  location                          = var.azurerm_resource_group-location
  resource_group_name               = var.azurerm_resource_group-name
  administrator_login               = var.azure-database-username
  administrator_login_password      = var.azure-database-password
  sku_name                          = var.database-server-size
  storage_mb                        = var.storage-size-MB
  version                           = var.mysql-version
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"

}
resource "azurerm_mysql_firewall_rule" "public" {
  name                = "allowpublic"
  resource_group_name = var.azurerm_resource_group-name
  server_name         = azurerm_mysql_server.mysql_db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
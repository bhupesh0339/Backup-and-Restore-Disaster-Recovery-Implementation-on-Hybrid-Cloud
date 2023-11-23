output "production-db-endpoint" {
  value = azurerm_mysql_server.mysql_db.fqdn
}
output "db-username" {
  value = azurerm_mysql_server.mysql_db.administrator_login
}
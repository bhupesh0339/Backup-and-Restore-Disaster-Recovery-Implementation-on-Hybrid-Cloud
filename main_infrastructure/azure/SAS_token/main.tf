data "azurerm_storage_account_sas" "sas_token" {
  connection_string = var.storage_account_connection_string
  https_only        = false
  signed_version    = "2017-07-29"
  resource_types {
    service   = true
    container = true
    object    = true
  }
  services {
    blob  = true
    queue = true
    table = true
    file  = true
  }
  start  = "2018-03-21T00:00:00Z"
  expiry = "2025-03-21T00:00:00Z"
  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = false
    filter  = false
  }
}
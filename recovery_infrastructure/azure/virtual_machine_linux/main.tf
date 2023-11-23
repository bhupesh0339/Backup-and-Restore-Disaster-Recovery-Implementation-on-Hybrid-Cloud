resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.virtual_machine_name
  resource_group_name   = var.azurerm_resource_group-name
  location              = var.azurerm_resource_group-location
  size                  = var.vm_size
  admin_username        = var.ssh_admin_user
  network_interface_ids = [var.network_interface_card]
  admin_ssh_key {
    username   = var.ssh_admin_user
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.disk_storage_account_type
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

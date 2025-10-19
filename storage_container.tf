# Storage Account (uses existing provider and RG data source)



resource "azurerm_storage_account" "storage_account" {
  name                     = "myretailsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    workload = "retail"
    env      = "dev"
  }
}

resource "azurerm_storage_container" "storage_container" {
  name                 = "myretailcontainer"
  storage_account_id   = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

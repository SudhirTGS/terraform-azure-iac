# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
  # Supply SP credentials via variables (recommended over hardcoding)
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Use existing Resource Group instead of creating a new one
data "azurerm_resource_group" "existing" {
  name = "rg-retail-network-east-us"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tfexample" {
  name                = "my-retail-vnet"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/24"] # wider block to accommodate subnet
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tfexample" {
  name                 = "my-retail-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.tfexample.name
  address_prefixes     = ["10.0.0.0/28"] # smallest block that yields ≥5 usable IPs
}

# Create a Network Interface
resource "azurerm_network_interface" "tfexample" {
  name                = "my-retail-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "my-retail-nic-ip-config"
    subnet_id                     = azurerm_subnet.tfexample.id
    private_ip_address_allocation = "Dynamic"
  }
}


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

resource "azurerm_network_interface" "tfexample_win" {
  name                = "my-retail-nic-2"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "my-retail-nic-2-ip-config"
    subnet_id                     = azurerm_subnet.tfexample.id
    private_ip_address_allocation = "Dynamic"
  }
}

#create a Virtual Machine in subnet
resource "azurerm_linux_virtual_machine" "tfexample" {
  name                = "my-retail-vm"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
 #update this size to next size as getting error Please try another size
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Azureuser@12345"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.tfexample.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

#create  windows VM in subnet
resource "azurerm_windows_virtual_machine" "tfexample" {
  name                = "my-retail-wn-vm"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Azureuser@12345"  
  network_interface_ids = [
    azurerm_network_interface.tfexample_win.id,
  ]
  computer_name = "retailwinvm"  # <= 15 chars to satisfy Windows hostname limit

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

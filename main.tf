# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
  # Supply SP credentials via variables (recommended over hardcoding)
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Create the Resource Group (was previously a data source)
resource "azurerm_resource_group" "rg" {
  name     = "rg-retail-network-east-us"
  location = "East US"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "my-retail-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/24"] # wider block to accommodate subnet
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "my-retail-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/28"] # smallest block that yields ≥5 usable IPs
}

# Create a Network Interface
resource "azurerm_network_interface" "nic_linux" {
  name                = "my-retail-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my-retail-nic-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_win" {
  name                = "my-retail-nic-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my-retail-nic-2-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#create a linux Virtual Machine in subnet
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "my-retail-linux-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 #update this size to next size as getting error Please try another size
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Azureuser@12345"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_linux.id,
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
resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                = "my-retail-wn-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Azureuser@12345"  
  network_interface_ids = [
    azurerm_network_interface.nic_win.id,
  ]
  computer_name = "my-retail-wn-vm"  # <= 15 chars to satisfy Windows hostname limit

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

provider "azurerm" {
  features {}
  subscription_id = " "
  client_id       = " "
  client_secret   = " "
  tenant_id       = " "
}
resource "azurerm_resource_group" "docker" {
  name     = "docker"
  location = "centralindia"
}

resource "azurerm_virtual_network" "docker-vnet" {
  name                = "docker-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.docker.location
  resource_group_name = azurerm_resource_group.docker.name
}

resource "azurerm_subnet" "sam" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.docker.name
  virtual_network_name = azurerm_virtual_network.docker-vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_security_group" "dockertest-nsg" {
  name                = "dockertest-nsg"
  location            = azurerm_resource_group.docker.location
  resource_group_name = azurerm_resource_group.docker.name

}

resource "azurerm_public_ip" "testing" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.docker.name
  location            = azurerm_resource_group.docker.location
  allocation_method   = "Static"
 }


resource "azurerm_network_interface" "dockertest287" {
  name                = "dockertest287-nic"
  location            = azurerm_resource_group.docker.location
  resource_group_name = azurerm_resource_group.docker.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sam.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.testing.id
  }
}

resource "azurerm_linux_virtual_machine" "ram" {
  name                = "ram"
  resource_group_name = azurerm_resource_group.docker.name
  location            = azurerm_resource_group.docker.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Terralogic@09"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.dockertest287.id,
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

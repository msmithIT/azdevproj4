terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "TerraFp4" {
  name     = "terrafrg-p4"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vtnetp4" {
  name                = "vtnetp4"
  location            = azurerm_resource_group.TerraFp4.location
  resource_group_name = azurerm_resource_group.TerraFp4.name
  address_space       = ["10.0.0.0/16"]


  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "snetp4" {
  name                 = "snetp4"
  resource_group_name  = azurerm_resource_group.TerraFp4.name
  virtual_network_name = azurerm_virtual_network.vtnetp4.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "ntwksg-p4"{
  name                = "ntwksg-p4"
  location            = azurerm_resource_group.TerraFp4.location
  resource_group_name = azurerm_resource_group.TerraFp4.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "ntwksr-p4" {
  name                        = "ntwksr-p4"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.TerraFp4.name
  network_security_group_name = azurerm_network_security_group.ntwksg-p4.name
}

resource "azurerm_subnet_network_security_group_association" "snsga-p4" {
  subnet_id                 = azurerm_subnet.snetp4.id
  network_security_group_id = azurerm_network_security_group.ntwksg-p4.id
}

resource "azurerm_network_interface" "ntwk-nic-p4" {
  name                = "ntwk-nic-p4"
  location            = azurerm_resource_group.TerraFp4.location
  resource_group_name = azurerm_resource_group.TerraFp4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snetp4.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "tflvm-p4" {
  name                            = "tflvm-p4"
  resource_group_name             = azurerm_resource_group.TerraFp4.name
  location                        = azurerm_resource_group.TerraFp4.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "abc59!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ntwk-nic-p4.id,
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
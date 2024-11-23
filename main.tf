
locals {
  resource_group = "${var.prefix}${random_integer.number.result}"
}

resource "random_integer" "number" {
  min = 10000
  max = 99999
}

 

resource "azurerm_resource_group" "resourcerg" {
  name     = local.resource_group
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}vn"
  resource_group_name = azurerm_resource_group.resourcerg.name
  location            = var.location
  address_space       = ["11.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}subnet"
  resource_group_name  = azurerm_resource_group.resourcerg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["11.0.35.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}nsg"
  resource_group_name = azurerm_resource_group.resourcerg.name
  location            = var.location
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "AllowRDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  source_address_prefix       = "*"
  resource_group_name         = azurerm_resource_group.resourcerg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "internet" {
  name                        = "DenyInternet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "Internet"
  source_address_prefix       = "*"
  resource_group_name         = azurerm_resource_group.resourcerg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnetass" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pubilcip" {
  name                = "${var.prefix}ip"
  resource_group_name = azurerm_resource_group.resourcerg.name
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}


resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}nic"
  resource_group_name = azurerm_resource_group.resourcerg.name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubilcip.id
  }
}




resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "${var.prefix}vm1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.resourcerg.name
  size                  = "Standard_B2s"
  admin_username        = var.user
  admin_password        = var.pass
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

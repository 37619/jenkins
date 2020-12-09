##variables
variable "prefix" {
  default = "ankita-poc"
}

variable "location" {
    default = "Central US"
}

variable "resource_group_name" {
    default = "ABInBev_PoC"
}

variable "vm_size" {
    default = "Standard_DS1_v2"
}

##NIC
resource "azurerm_virtual_network" "main" {
  name                = "ankita-poc-network"
  address_space       = ["10.1.0.0/16"]
  location            = "Central US"
  resource_group_name = "ABInBev_PoC"
}

resource "azurerm_subnet" "internal" {
  name                 = "default"
  resource_group_name  = "ABInBev_PoC"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_network_interface" "vm_interface" {
  name                = "ankita-poc-nic"
  location            = "Central US"
  resource_group_name = "ABInBev_PoC"

  ip_configuration {
    name                          = "ankita-poc-testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

####################################################VIRTUAL MACHINE
resource "azurerm_virtual_machine" "vm" {
  name                  = "ankita-poc-vm"
  location              = "Central US"
  resource_group_name   = "ABInBev_PoC"
  network_interface_ids = [azurerm_network_interface.vm_interface.id]
  vm_size               = "Standard_DS1_v2"

 storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

 storage_os_disk {
    name              = "ankita-poc-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "dev"
  }
}
resource "azurerm_resource_group" "SGRG02" {

    name = "${var.prefix}-resourceGroup"
    location = var.location
    tags = { test = "testRG" }
  
}

resource "azurerm_virtual_network" "shubhamVnet02" {
    name = "${var.prefix}-vnet"
    location = azurerm_resource_group.SGRG02.location
    resource_group_name = azurerm_resource_group.SGRG02.name
    address_space = ["10.60.0.0/22"]
}
   resource "azurerm_subnet" "subnet01" {
    name = "subnet01"
    resource_group_name = azurerm_resource_group.SGRG02.name
    virtual_network_name = azurerm_virtual_network.shubhamVnet02.name
    address_prefixes = ["10.60.0.0/24"]
    
   }

resource "azurerm_public_ip" "publicip" {
    count = var.instanceCount
    name = "${var.prefix}-PIP${(count.index)+1}"
    allocation_method = "Dynamic"
    location = azurerm_resource_group.SGRG02.location
    sku = "Basic"
    resource_group_name = azurerm_resource_group.SGRG02.name
    sku_tier = "Regional"
}

resource "azurerm_network_interface" "NIC01" {
    count = var.instanceCount
    name = "${var.prefix}-NIC${count.index}"
    location = azurerm_resource_group.SGRG02.location
    resource_group_name = azurerm_resource_group.SGRG02.name

    ip_configuration {
      name = "nicipconfig"
      private_ip_address_allocation = "Dynamic"
      subnet_id = azurerm_subnet.subnet01.id
      public_ip_address_id = azurerm_public_ip.publicip[count.index].id
    }
  
}

resource "azurerm_windows_virtual_machine" "WinVM" {
    count = var.instanceCount
    name = "${var.prefix}-WinVM${count.index}"
    network_interface_ids = [
          azurerm_network_interface.NIC01[count.index].id, 
    ]

    resource_group_name = azurerm_resource_group.SGRG02.name
    location = var.location
    admin_username = "azureadmin"
    admin_password = "Azure@123456"
    size = "Standard_F2"
    
    os_disk {
      storage_account_type = "Standard_LRS"
      caching = "ReadWrite"
    }

    source_image_reference {
      offer = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku = "2016-Datacenter"
      version = "latest"
    }
}


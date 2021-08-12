data "azurerm_subnet" "selected" {
  name                 = var.subnet_opts.name
  virtual_network_name = var.subnet_opts.virtual_network_name
  resource_group_name  = var.subnet_opts.resource_group_name
}

data "azurerm_resource_group" "selected" {
  name = var.resource_group
}

# optional - see var.create_public_ip
resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.prefix}-stackblitz-pip"
  resource_group_name = data.azurerm_resource_group.selected.name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-stackblitz-nic"
  resource_group_name = data.azurerm_resource_group.selected.name
  location            = var.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.selected.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-stackblitz-ingress"
  resource_group_name = data.azurerm_resource_group.selected.name
  location            = var.location

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = var.vpn_available ? "${azurerm_network_interface.main.private_ip_address}" : "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https"
    priority                   = 115
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "kubernetes"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "6443"
    destination_address_prefix = var.vpn_available ? "${azurerm_network_interface.main.private_ip_address}" : "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "kotsadm"
    priority                   = 140
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "8800"
    destination_address_prefix = var.vpn_available ? "${azurerm_network_interface.main.private_ip_address}" : "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "grafana"
    priority                   = 150
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "30902"
    destination_address_prefix = var.vpn_available ? "${azurerm_network_interface.main.private_ip_address}" : "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-stackblitz-vm"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.selected.name
  size                = var.vm_size
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_username = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.public_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = var.vm_disk_size
  }
}

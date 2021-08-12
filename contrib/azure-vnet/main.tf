provider "azurerm" {
  features {}
}

locals {
  prefix         = "maple"
  location       = "centralus"
  resource_group = "adam-dev"
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group
}

resource "azurerm_subnet" "main" {
  name                 = "${local.prefix}-subnet"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

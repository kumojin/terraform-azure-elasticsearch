resource "random_string" "vm-login-password" {
  length = 16
  special = true
  override_special = "!@#%&-_"
}

resource "azurerm_resource_group" "elasticsearch" {
  location = var.location
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "elasticsearch_vnet" {
  name                = "es-${var.es_cluster}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.elasticsearch.name
  address_space       = [ "10.1.0.0/24" ]
}

resource "azurerm_subnet" "elasticsearch_subnet" {
  name                 = "es-${var.es_cluster}-subnet"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  virtual_network_name = azurerm_virtual_network.elasticsearch_vnet.name
  address_prefixes     = [ "10.1.0.0/24" ]
}

resource "azurerm_resource_group" "elasticsearch" {
  location = var.location
  name = "es-${var.resource_group_name}"
}

resource "azurerm_virtual_network" "elasticsearch_vnet" {
  name                = "es-${var.cluster_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.elasticsearch.name
  address_space       = [ "10.1.0.0/24" ]
}

resource "azurerm_subnet" "elasticsearch_subnet" {
  name                 = "es-${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  virtual_network_name = azurerm_virtual_network.elasticsearch_vnet.name
  address_prefixes     = [ "10.1.0.0/24" ]
}

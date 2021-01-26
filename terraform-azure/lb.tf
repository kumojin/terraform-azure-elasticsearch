resource "azurerm_public_ip" "clients" {
  name                = "es-${var.es_cluster}-clients-lb-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.elasticsearch.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "clients" {
  name = "es-${var.es_cluster}-clients-lb"
  location = var.location
  resource_group_name = azurerm_resource_group.elasticsearch.name

  frontend_ip_configuration {
    name = "es-${var.es_cluster}-ip"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.clients.id
  }
}

resource "azurerm_lb_backend_address_pool" "clients-lb-backend" {
  name = "es-${var.es_cluster}-clients-lb-backend"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  loadbalancer_id = azurerm_lb.clients.id
}

resource "azurerm_lb_probe" "clients-httpprobe" {
  name = "es-${var.es_cluster}-clients-lb-probe"
  port = 9200
  protocol = "Http"
  request_path = "/_cat/health"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  loadbalancer_id = azurerm_lb.clients.id
}

// Elasticsearch access
resource "azurerm_lb_rule" "clients-lb-rule" {
  name = "es-${var.es_cluster}-clients-lb-rule"
  backend_port = 9200
  frontend_port = 9200
  frontend_ip_configuration_name = "es-${var.es_cluster}-ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.clients-lb-backend.id
  protocol = "Tcp"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  loadbalancer_id = azurerm_lb.clients.id
}

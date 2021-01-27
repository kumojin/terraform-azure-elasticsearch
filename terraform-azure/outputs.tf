output "resource_group_name" {
  value = azurerm_resource_group.elasticsearch.name
}

output "vnet_name" {
  value = azurerm_virtual_network.elasticsearch_vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.elasticsearch_vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.elasticsearch_subnet.id
}

output "clients_lb_public_ip" {
  value = azurerm_public_ip.clients.ip_address
}

output "es_image_id" {
  value = data.azurerm_image.elasticsearch.name
}

output "kibana_image_id" {
  value = data.azurerm_image.kibana.name
}

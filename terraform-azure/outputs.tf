output "es_image_id" {
  value = data.azurerm_image.elasticsearch.name
}

output "kibana_image_id" {
  value = data.azurerm_image.kibana.name
}

output "vm_password" {
  value = random_string.vm-login-password.result
}
data "template_file" "client_userdata_script" {
  template = file("${path.module}/../templates/user_data.kibana.sh")

  vars = {
    cluster_name            = var.cluster_name
    data_node_count         = var.data_count
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "client-nodes" {
  name                 = "vmss-es-${var.cluster_name}-clients"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  location             = var.location

  source_image_id      = data.azurerm_image.kibana.id
  sku                  = var.client_instance_type
  instances            = var.client_count

  admin_username                  = "ubuntu"
  disable_password_authentication = true # admin_password disables ssh

  computer_name_prefix = "${var.cluster_name}-client"
  custom_data          = base64encode(data.template_file.client_userdata_script.rendered)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.client_ssh_key
  }

  network_interface {
    name = "es-${var.cluster_name}-net-profile"
    primary = true

    ip_configuration {
      name = "es-${var.cluster_name}-ip-profile"
      primary = true
      subnet_id = azurerm_subnet.elasticsearch_subnet.id
      load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.clients-lb-backend.id ]
    }
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS" # TODO: SSD option?
  }
}

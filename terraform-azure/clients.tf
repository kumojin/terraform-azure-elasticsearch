data "template_file" "client_userdata_script" {
  template = file("${path.module}/../templates/user_data.sh")

  vars = {
    volume_name             = ""
    elasticsearch_data_dir  = "/var/lib/elasticsearch"
    elasticsearch_logs_dir  = var.elasticsearch_logs_dir
    heap_size               = var.client_heap_size
    es_cluster              = var.es_cluster
    master                  = false
    data                    = false
    bootstrap_node          = false
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
    xpack_monitoring_host   = var.xpack_monitoring_host
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "client-nodes" {
  name                 = "es-${var.es_cluster}-client-nodes"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  location             = var.location

  source_image_id      = data.azurerm_image.kibana.id
  sku                  = var.client_instance_type
  instances            = var.client_count

  admin_username       = "ubuntu"
  admin_password       = random_string.vm-login-password.result
  computer_name_prefix = "${var.es_cluster}-client"
  custom_data          = base64encode(data.template_file.client_userdata_script.rendered)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_key
  }

  network_interface {
    name = "es-${var.es_cluster}-net-profile"
    primary = true

    ip_configuration {
      name = "es-${var.es_cluster}-ip-profile"
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

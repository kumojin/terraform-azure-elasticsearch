data "template_file" "master_userdata_script" {
  template = file("${path.module}/../templates/user_data.elasticsearch.sh")

  vars = {
    volume_name             = ""
    elasticsearch_data_dir  = "/var/lib/elasticsearch"
    elasticsearch_logs_dir  = var.elasticsearch_logs_dir
    heap_size               = var.master_heap_size
    cluster_name            = var.cluster_name
    master                  = true
    data                    = false
    bootstrap_node          = false
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
    xpack_monitoring_host   = var.xpack_monitoring_host
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "master-nodes" {
  name                 = "vmss-es-${var.cluster_name}-masters"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  location             = var.location

  source_image_id      = data.azurerm_image.elasticsearch.id
  sku                  = var.master_instance_type
  instances            = var.master_count
  
  admin_username                  = "ubuntu"
  disable_password_authentication = true # admin_password disables ssh

  computer_name_prefix = "${var.cluster_name}-master"
  custom_data          = base64encode(data.template_file.master_userdata_script.rendered)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.master_ssh_key
  }

  network_interface {
    name = "es-${var.cluster_name}-net-profile"
    primary = true

    ip_configuration {
      name = "es-${var.cluster_name}-ip-profile"
      primary = true
      subnet_id = azurerm_subnet.elasticsearch_subnet.id
      load_balancer_backend_address_pool_ids = var.client_count == 0 ? [ azurerm_lb_backend_address_pool.clients-lb-backend.id ] : []
    }
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS" # TODO: SSD option?
  }
}

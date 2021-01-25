data "template_file" "data_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars = {
    volume_name             = ""
    elasticsearch_data_dir  = var.elasticsearch_data_dir
    elasticsearch_logs_dir  = var.elasticsearch_logs_dir
    heap_size               = var.data_heap_size
    es_cluster              = var.es_cluster
    es_environment          = "${var.environment}-${var.es_cluster}"
    security_groups         = ""
    availability_zones      = ""
    minimum_master_nodes    = format("%d", floor(var.masters_count / 2 + 1))
    master                  = "false"
    data                    = "true"
    bootstrap_node          = "false"
    http_enabled            = "true"
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
    masters_count           = var.masters_count
    xpack_monitoring_host   = var.xpack_monitoring_host
  }
}

resource "azurerm_virtual_machine_scale_set" "data-nodes" {
  count = var.datas_count == 0 ? 0 : 1

  name = "es-${var.es_cluster}-data-nodes"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  location = var.location
  sku {
    name = var.data_instance_type
    tier = "Standard"
    capacity = var.datas_count
  }
  upgrade_policy_mode = "Manual"
  overprovision = false

  os_profile {
    computer_name_prefix = "${var.es_cluster}-data"
    admin_username = "ubuntu"
    admin_password = random_string.vm-login-password.result
    custom_data = data.template_file.data_userdata_script.rendered
  }

  network_profile {
    name = "es-${var.es_cluster}-net-profile"
    primary = true
    accelerated_networking = true

    ip_configuration {
      name = "es-${var.es_cluster}-ip-profile"
      primary = true
      subnet_id = azurerm_subnet.elasticsearch_subnet.id
      load_balancer_backend_address_pool_ids = var.clients_count == 0 ? [ azurerm_lb_backend_address_pool.clients-lb-backend.id ] : []
    }
  }

  storage_profile_image_reference {
    id = data.azurerm_image.elasticsearch.id
  }

  storage_profile_os_disk {
    caching        = "ReadWrite"
    create_option  = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.data_ssh_key
    }
  }

  storage_profile_data_disk {
    lun            = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = var.elasticsearch_volume_size
    managed_disk_type = "Standard_LRS"
  }
}

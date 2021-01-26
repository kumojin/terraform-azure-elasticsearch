variable "location" {
  description = "Azure Region where resources will be created"
  type = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type = string
}

variable "es_cluster" {
  description = "Name of the elasticsearch cluster. Used in node discovery"
  default = "my-cluster"
}

variable "data_instance_type" {
  type = string
  default = "Standard_D4S_v3" # 4x vCPU, 16GB RAM
}

# If the master will be a data node, the data_instance_type should be used
variable "master_instance_type" {
  type = string
  default = "Standard_D2S_v3" # 2x vCPU, 8GB RAM
}

variable "client_instance_type" {
  type = string
  default = "Standard_A2_v2" # 2x vCPU, 4GB RAM
}

variable "elasticsearch_volume_size" {
  type = string
  default = "100" # GB
}

variable "elasticsearch_data_dir" {
  default = "/mnt/elasticsearch/data"
}

variable "elasticsearch_logs_dir" {
  default = "/var/log/elasticsearch"
}

# Default elasticsearch heap size
variable "data_heap_size" {
  type = string
  default = "8g"
}

# https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#heap-size-settings
# Should be 50% of the total memory vailable
variable "master_heap_size" {
  type = string
  default = "4g"
}

variable "masters_count" {
  type = number
  default = 3
}

variable "master_with_data" {
  description = "A master node could be a data node too on small cluster, it's recommanded to separate the 2 instance type but not mandatory"
  default = "false"
}
variable "datas_count" {
  type = number
  default = 3
}

variable "clients_count" {
  type = number
  default = 0
}

# x-pack security on the cluster
variable "security_enabled" {
  default = false
}

# x-pack monitoring on the cluster
variable "monitoring_enabled" {
  default = true
}

variable "xpack_monitoring_host" {
  description = "ES host to send monitoring data"
  default     = "self"
}

variable "client_ssh_key" {
  type = string
}

variable "data_ssh_key" {
  type = string
}

variable "master_ssh_key" {
  type = string
}

variable "location" {
  type = string
  default = "East US 2"
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}


variable "es_cluster" {
  description = "Name of the elasticsearch cluster, used in node discovery"
  default = "my-cluster"
}

variable "key_path" {
  description = "Key name to be used with the launched instances."
  default = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  default = "default"
}

variable "data_instance_type" {
  type = string
  default = "Standard_D4S_v3"
}

# If the master will be a data node too, you may want to switch the instance type to Standard_D4S_v3
variable "master_instance_type" {
  type = string
  default = "Standard_D2S_v3"
}

variable "client_instance_type" {
  type = string
  default = "Standard_A2_v2"
}

variable "elasticsearch_volume_size" {
  type = string
  default = "100" # gb
}

variable "use_instance_storage" {
  default = true
}

variable "associate_public_ip" {
  default = true
}

variable "elasticsearch_data_dir" {
  default = "/mnt/elasticsearch/data"
}

variable "elasticsearch_logs_dir" {
  default = "/var/log/elasticsearch"
}

# default elasticsearch heap size
variable "data_heap_size" {
  type = string
  default = "8g"
}

variable "master_heap_size" {
  description = "Should be 50% of the total memory vailable"
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

# whether or not to enable x-pack security on the cluster
variable "security_enabled" {
  default = false
}

# whether or not to enable x-pack monitoring on the cluster
variable "monitoring_enabled" {
  default = true
}

variable "xpack_monitoring_host" {
  description = "ES host to send monitoring data"
  default     = "self"
}

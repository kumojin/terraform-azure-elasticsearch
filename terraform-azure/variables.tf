# General cluster options
variable "images_resource_group_name" {
  description = "Name of the Resource Group with Kibana and ES images"
  type = string
}

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

# TODO: Remove once secret management in place
variable "ssh_key" {
  type = string
}

# General node options
# ====================
variable "elasticsearch_data_dir" {
  default = "/mnt/elasticsearch/data"
}

variable "elasticsearch_logs_dir" {
  default = "/var/log/elasticsearch"
}

variable "elasticsearch_volume_size" {
  description = "In GB"
  type = string
  default = "100"
}

variable "security_enabled" {
  description = "x-pack security on the cluster"
  default = false
}

variable "monitoring_enabled" {
  description = "x-pack monitoring on the cluster"
  default = true
}

variable "xpack_monitoring_host" {
  default = "self"
}

# Data nodes
# ==========
variable "data_count" {
  type = number
}

variable "data_instance_type" {
  type = string
}

# TODO: Check recommendation. IRC should be total allocated to JVM
variable "data_heap_size" {
  type = string
}

# Master nodes
# ============
variable "master_count" {
  type = number
}


# Recommended to NOT have master node as a data node. OK for small clusters
variable "master_with_data" {
  default = "false"
}

# If the master will be a data node, the data_instance_type should be used
variable "master_instance_type" {
  type = string
}

# https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#heap-size-settings
# Should be 50% of the total memory vailable
variable "master_heap_size" {
  type = string
}

# Client nodes
# ============
variable "client_count" {
  type = number
}

variable "client_instance_type" {
  type = string
}

variable "client_heap_size" {
  type = string
}

# ###############
# required values
# ###############

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
}

variable "name" {
  description = "The name of the redis service"
}

variable "location" {
  description = "Region where the resources are created."
}

# ###############
# optional values
# ###############

variable "tier_settings" {
  type        = "map"
  description = "Redis tier settings"

  default = {
    family   = "C" # 
    sku_name = "Basic"
    capacity = 0
  }
}

variable "non_ssl_port" {
  description = "Enable non SSL port of redis"
  default     = "false"
}

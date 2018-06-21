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

variable "tier" {
  description = "Redis tier setting Basic, Standard or Premium"
  default     = "Premium" 
}

# ###############
# optional values
# ###############

variable "family" {
  type        = "map"
  description = "Redis tier family.  "

  default = {
    	Basic    = "C"
    	Standard = "C"
        Premium  = "P"
    }
}

variable "capacity" {
  description = "Size of redis cache to deploy"
  default     = 1 
}

variable "shard_count" {
  description = "Number of shards for Redis cluster configuration"
  default = 2
}

variable "redis_configuration" {
  description = "Redis configuration"
  type = "list"

  default = [{
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"	
  }] 
}

variable "non_ssl_port" {
  description = "Enable non SSL port of redis"
  default     = "false"
}

variable "enable_cluster" {
  description = "Enable Redis cluster configurations in Premium tier" 
  default = "true"
}

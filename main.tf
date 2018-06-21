provider "azurerm" {
  version = ">= 1.6.0"
}

terraform {
  required_version = ">= 0.11.0"
}

# Resource Group Creation
resource "azurerm_resource_group" "redis" {
  name     = "${var.resource_group_name == "" ? replace(var.name, "/[^a-z0-9]/", "RG") : var.resource_group_name}"
  location = "${var.location}"
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis" {
  count               = "${(var.tier != "Premium" && var.enable_cluster != "true" ? 1 : 0)}"
  name                = "${var.name}"
  location            = "${azurerm_resource_group.redis.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.capacity}"
  family              = "${lookup(var.family, var.tier)}"
  sku_name            = "${var.tier}"
  enable_non_ssl_port = "${var.non_ssl_port}"
  redis_configuration = {}
}

# Redis Premium tier with clustering 
resource "azurerm_redis_cache" "redis-cluster" {
  count               = "${(var.tier == "Premium" && var.enable_cluster == "true" ? 1 : 0)}"
  # count               = "${var.enable_cluster == "true" ? 1 : 0}"
  name                = "${var.name}"
  location            = "${azurerm_resource_group.redis.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.capacity}"
  family              = "${lookup(var.family, var.tier)}"
  sku_name            = "${var.tier}"
  enable_non_ssl_port = "${var.non_ssl_port}"
  
  shard_count         = "${var.shard_count}"
  redis_configuration = "${var.redis_configuration}"
}

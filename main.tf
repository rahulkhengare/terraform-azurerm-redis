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
  name                = "${var.name}"
  location            = "${azurerm_resource_group.redis.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.tier_settings["capacity"]}"
  family              = "${var.tier_settings["family"]}"
  sku_name            = "${var.tier_settings["sku_name"]}"
  enable_non_ssl_port = "${var.non_ssl_port}"
  redis_configuration = {}
}

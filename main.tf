provider "azurerm" {
  version = ">= 1.6.0"
}

terraform {
  required_version = ">= 0.11.0"
}

resource "random_id" "redis-sa" {
  keepers = {
    redis-sa = "${var.name}"
  }

  byte_length = 6
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
  name                = "${var.name}"
  location            = "${azurerm_resource_group.redis.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.capacity}"
  family              = "${lookup(var.family, var.tier)}"
  sku_name            = "${var.tier}"
  enable_non_ssl_port = "${var.non_ssl_port}"
  
  shard_count         = "${var.shard_count}"
  redis_configuration {
			maxmemory_reserved = "${var.redis_configuration["maxmemory_reserved"]}"
			maxmemory_delta    = "${var.redis_configuration["maxmemory_delta"]}"
			maxmemory_policy   = "${var.redis_configuration["maxmemory_policy"]}"
  }
}

# Redis Premium tier with backup
resource "azurerm_storage_account" "redis-backup-sa" {
  count                    = "${(var.tier == "Premium" && var.enable_backup == "true" ? 1 : 0)}"
  name                     = "redisbackup${lower(random_id.redis-sa.hex)}"
  resource_group_name      = "${azurerm_resource_group.redis.name}"
  location                 = "${azurerm_resource_group.redis.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_redis_cache" "redis-backup" {
  count               = "${(var.tier == "Premium" && var.enable_backup == "true" ? 1 : 0)}"
  name                = "${var.name}"
  location            = "${azurerm_resource_group.redis.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.capacity}"
  family              = "${lookup(var.family, var.tier)}"
  sku_name            = "${var.tier}"
  enable_non_ssl_port = "${var.non_ssl_port}"
  redis_configuration = {
			rdb_backup_enabled              = "true"
			rdb_backup_frequency            = "${var.redis_configuration["rdb_backup_frequency"]}"
			rdb_backup_max_snapshot_count   = "${var.redis_configuration["rdb_backup_max_snapshot_count"]}"
			rdb_storage_connection_string = "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.redis-backup-sa.primary_blob_endpoint};AccountName=${azurerm_storage_account.redis-backup-sa.name};AccountKey=${azurerm_storage_account.redis-backup-sa.primary_access_key}"
  }
}

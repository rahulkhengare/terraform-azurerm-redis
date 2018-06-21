# Terraform module for Azure Redis Cache Service

> Deploy a Redis cache service on Azure with minimal configuration

## Features

- Create resource group, redis cache Platform as a service (PaaS)
- Customize redis configuration and tier settings

## Usage


Deploy a redis cache with default settings

```
module "redis" {
    source              = "rahulkhengare/redis/azurerm"
    name                = "testredis" #Should be unique 
    resource_group_name = "testredisRG"
}

Outputs:
```

## Changelog


## License

[MIT](./LICENSE) © [Rahul Khengare](https://www.linkedin.com/in/rahulkhengare)

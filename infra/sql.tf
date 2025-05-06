resource "azurerm_mssql_server" "example" {
  name                         = "kuberno-example-sqlserver-${random_string.random_sql_server_suffix.result}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = random_string.username.result
  administrator_login_password = random_password.password.result
}

# https://learn.microsoft.com/en-gb/rest/api/sql/firewall-rules/create-or-update?view=rest-sql-2023-08-01&tabs=HTTP#request-body
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.example.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "random_string" "random_sql_server_suffix" {
  length  = 16
  special = false
  upper   = false
}

resource "random_string" "username" {
  length  = 16
  special = false
  upper   = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_mssql_database" "example" {
  name        = "kuberno-example-db"
  server_id   = azurerm_mssql_server.example.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 1
  sku_name    = "Basic"

  read_scale                     = false
  storage_account_type           = "Local"
  read_replica_count             = 0
  min_capacity                   = 0
  maintenance_configuration_name = "SQL_Default"
  ledger_enabled                 = false

  zone_redundant = false


}

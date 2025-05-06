resource "azurerm_service_plan" "example" {
  name                = "kuberno-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "F1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "example" {
  name                = "kuberno-example-app-${random_string.random_web_app_suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.example.connection_string
  }

  site_config {

    virtual_application {
      physical_path = "site\\wwwroot"
      preload       = false
      virtual_path  = "/"
    }

    always_on = false
    application_stack {
      dotnet_version = "v4.0"
    }
  }
  connection_string {
    name  = "MyDbConnection"
    value = "Data Source=tcp:${azurerm_mssql_server.example.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.example.name};User Id=${random_string.username.result};Password=${random_password.password.result}"
    type  = "SQLAzure"
  }

  tags = {
    "hidden-link: /app-insights-conn-string" : azurerm_application_insights.example.connection_string
    "hidden-link: /app-insights-resource-id" : replace(provider::azurerm::normalise_resource_id(azurerm_application_insights.example.id), "Microsoft.Insights", "microsoft.insights")
  }
}

resource "random_string" "random_web_app_suffix" {
  length  = 16
  special = false
  upper   = false
}
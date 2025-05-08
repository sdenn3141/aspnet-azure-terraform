resource "azurerm_application_insights" "example" {
  name                = "kuberno-example-app-insights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "kuberno-example-ws"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights_standard_web_test" "example" {
  name                    = "kuberno-example-availability-test"
  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  application_insights_id = azurerm_application_insights.example.id
  geo_locations           = ["emea-ru-msa-edge", "emea-se-sto-edge", "emea-nl-ams-azr", "emea-gb-db3-azr", "emea-fr-pra-edge"]
  enabled = true
  request {
    url = "http://${azurerm_windows_web_app.example.default_hostname}/"
  }
}

resource "azurerm_monitor_action_group" "example" {
  name                = "example-actiongroup"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "exampleact"

  email_receiver {
    name          = "sdenn3141"
    email_address = var.ag_email_address
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${azurerm_windows_web_app.example.name}"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_service_plan.example.id]
  description         = "Action will be triggered when CPU average is greater than 50."

  criteria {
    metric_namespace = "microsoft.web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}

resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "memory-alert-${azurerm_windows_web_app.example.name}"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_service_plan.example.id]
  description         = "Action will be triggered when memory average is greater than 50."
  criteria {
    metric_namespace = "microsoft.web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}

resource "azurerm_monitor_metric_alert" "availability_alert" {
  name                = "availability-${azurerm_windows_web_app.example.name}"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_application_insights.example.id, azurerm_application_insights_standard_web_test.example.id]
  description         = "Action will be triggered when availability checks fail 3 times."

  application_insights_web_test_location_availability_criteria {
    failed_location_count = 3
    component_id = azurerm_application_insights.example.id
    web_test_id = azurerm_application_insights_standard_web_test.example.id

  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}

resource "azurerm_monitor_metric_alert" "mssql_dtu_alert" {
  name                = "mssql-dtu-usage-alert"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_mssql_database.example.id]
  description         = "Alert when DTU consumption exceeds 80%"
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}
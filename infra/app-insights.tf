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
  name                = "cpu-alert-${azureazurerm_windows_web_app.example.name}"
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
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "memory-alert-${azureazurerm_windows_web_app.example.name}"
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
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
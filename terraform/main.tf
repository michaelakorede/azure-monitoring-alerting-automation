locals {
  name_prefix = "monitor-${var.environment}"

  common_tags = merge(var.tags, {
    environment = var.environment
    managedBy   = "terraform"
    workload    = "monitoring-alerting"
  })
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "log-${local.name_prefix}"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_monitor_action_group" "operations" {
  name                = "ag-${local.name_prefix}-ops"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "ops"
  tags                = local.common_tags

  email_receiver {
    name                    = "cloud-operations"
    email_address           = var.ops_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "ma-${local.name_prefix}-cpu-high"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.target_resource_id]
  description         = "CPU average is above 80 percent for 10 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT10M"
  enabled             = true
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.operations.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_requests" {
  name                = "sqa-${local.name_prefix}-failed-requests"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  scopes              = [azurerm_log_analytics_workspace.monitoring.id]
  description         = "Detects elevated failed application requests."
  severity            = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  enabled              = true
  tags                 = local.common_tags

  criteria {
    query                   = file("${path.module}/../queries/failed-requests.kql")
    time_aggregation_method = "Count"
    threshold               = var.failed_request_threshold
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.operations.id]
  }
}


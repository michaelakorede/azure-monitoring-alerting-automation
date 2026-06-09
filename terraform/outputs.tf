output "resource_group_name" {
  value       = azurerm_resource_group.monitoring.name
  description = "Monitoring resource group name."
}

output "workspace_id" {
  value       = azurerm_log_analytics_workspace.monitoring.id
  description = "Log Analytics workspace ID."
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.operations.id
  description = "Azure Monitor action group ID."
}

output "metric_alert_id" {
  value       = azurerm_monitor_metric_alert.primary_metric.id
  description = "Primary metric alert resource ID."
}

output "activity_log_alert_id" {
  value       = try(azurerm_monitor_activity_log_alert.resource_group_delete[0].id, null)
  description = "Activity log alert resource ID when enabled."
}

output "failed_request_log_alert_id" {
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.failed_requests[0].id, null)
  description = "Failed request scheduled query alert resource ID when enabled."
}

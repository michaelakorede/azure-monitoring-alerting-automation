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


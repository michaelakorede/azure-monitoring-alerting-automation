variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "target_resource_id" {
  description = "Resource ID monitored by the metric alert."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/.+", var.target_resource_id))
    error_message = "target_resource_id must be a full Azure resource ID."
  }
}

variable "ops_email" {
  description = "Email address for operations notifications."
  type        = string
}

variable "metric_alert_name" {
  description = "Friendly name suffix for the primary metric alert."
  type        = string
  default     = "cpu-high"
}

variable "metric_namespace" {
  description = "Metric namespace for the monitored resource."
  type        = string
  default     = "Microsoft.Compute/virtualMachines"
}

variable "metric_name" {
  description = "Metric name used by the primary metric alert."
  type        = string
  default     = "Percentage CPU"
}

variable "metric_aggregation" {
  description = "Metric aggregation used by the primary metric alert."
  type        = string
  default     = "Average"
}

variable "metric_operator" {
  description = "Comparison operator used by the primary metric alert."
  type        = string
  default     = "GreaterThan"
}

variable "metric_threshold" {
  description = "Threshold used by the primary metric alert."
  type        = number
  default     = 80
}

variable "metric_alert_frequency" {
  description = "How often Azure Monitor evaluates the metric alert."
  type        = string
  default     = "PT5M"
}

variable "metric_alert_window_size" {
  description = "Time window used by the metric alert."
  type        = string
  default     = "PT10M"
}

variable "enable_failed_request_log_alert" {
  description = "Create the failed request scheduled query alert. Enable only after the workspace receives AppRequests data."
  type        = bool
  default     = false
}

variable "failed_request_threshold" {
  description = "Number of failed requests allowed during the query window."
  type        = number
  default     = 5
}

variable "enable_activity_log_alert" {
  description = "Create an activity log alert for resource group delete operations."
  type        = bool
  default     = true
}

variable "activity_log_alert_scope_id" {
  description = "Scope for activity log alert. Defaults to the current subscription."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    owner      = "cloud-operations"
    costCenter = "portfolio"
  }
}

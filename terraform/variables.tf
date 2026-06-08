variable "environment" {
  description = "Environment name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID monitored by the metric alert."
  type        = string
}

variable "ops_email" {
  description = "Email address for operations notifications."
  type        = string
}

variable "failed_request_threshold" {
  description = "Number of failed requests allowed during the query window."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    owner      = "cloud-operations"
    costCenter = "portfolio"
  }
}


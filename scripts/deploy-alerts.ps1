param(
    [string]$Environment = "dev",

    [string]$Location = "eastus",

    [Parameter(Mandatory = $true)]
    [string]$TargetResourceId,

    [Parameter(Mandatory = $true)]
    [string]$OpsEmail,

    [string]$MetricNamespace = "Microsoft.Compute/virtualMachines",

    [string]$MetricName = "Percentage CPU",

    [double]$MetricThreshold = 80,

    [switch]$EnableFailedRequestLogAlert,

    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"

$terraformDir = Join-Path $PSScriptRoot "..\terraform"
$planFile = "monitoring-alerts-$Environment.tfplan"
$envFile = Join-Path $PSScriptRoot "..\.deploy.env"

Write-Host "Checking Azure CLI account..."
az account show --only-show-errors | Out-Null

Push-Location $terraformDir
try {
    if (Test-Path "backend.hcl") {
        terraform init -backend-config="backend.hcl"
    }
    else {
        terraform init -backend=false
    }

    terraform fmt
    terraform validate
    terraform plan `
        -var "environment=$Environment" `
        -var "location=$Location" `
        -var "target_resource_id=$TargetResourceId" `
        -var "ops_email=$OpsEmail" `
        -var "metric_namespace=$MetricNamespace" `
        -var "metric_name=$MetricName" `
        -var "metric_threshold=$MetricThreshold" `
        -var "enable_failed_request_log_alert=$($EnableFailedRequestLogAlert.IsPresent.ToString().ToLowerInvariant())" `
        -out $planFile

    if ($AutoApprove) {
        terraform apply -auto-approve $planFile
    }
    else {
        terraform apply $planFile
    }

    $outputs = terraform output -json | ConvertFrom-Json
    @(
        "MONITORING_RESOURCE_GROUP=$($outputs.resource_group_name.value)"
        "LOG_ANALYTICS_WORKSPACE_ID=$($outputs.workspace_id.value)"
        "ACTION_GROUP_ID=$($outputs.action_group_id.value)"
        "METRIC_ALERT_ID=$($outputs.metric_alert_id.value)"
    ) | Set-Content -Path $envFile -Encoding utf8

    Write-Host "Deployment values written to $envFile"
}
finally {
    Pop-Location
}

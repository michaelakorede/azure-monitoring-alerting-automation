param(
    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$TargetResourceId,

    [Parameter(Mandatory = $true)]
    [string]$OpsEmail
)

$ErrorActionPreference = "Stop"

$terraformDir = Join-Path $PSScriptRoot "..\terraform"

Push-Location $terraformDir
try {
    terraform init
    terraform fmt
    terraform validate
    terraform plan `
        -var "environment=$Environment" `
        -var "location=$Location" `
        -var "target_resource_id=$TargetResourceId" `
        -var "ops_email=$OpsEmail" `
        -out "monitoring-alerts.tfplan"
    terraform apply "monitoring-alerts.tfplan"
}
finally {
    Pop-Location
}


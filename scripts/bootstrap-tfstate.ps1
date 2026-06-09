param(
    [string]$Environment = "dev",
    [string]$Location = "eastus",
    [string]$ResourceGroupName = "rg-tfstate-dev",
    [string]$ContainerName = "tfstate"
)

$ErrorActionPreference = "Stop"

az account show --only-show-errors | Out-Null

$suffix = Get-Random -Minimum 10000 -Maximum 99999
$storageAccountName = ("tfstatemonitor{0}{1}" -f $Environment, $suffix).ToLowerInvariant()
$storageAccountName = $storageAccountName -replace "[^a-z0-9]", ""
if ($storageAccountName.Length -gt 24) {
    $storageAccountName = $storageAccountName.Substring(0, 24)
}

az group create --name $ResourceGroupName --location $Location --output none
az storage account create `
    --name $storageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --allow-blob-public-access false `
    --output none

$storageKey = az storage account keys list `
    --resource-group $ResourceGroupName `
    --account-name $storageAccountName `
    --query "[0].value" `
    -o tsv

az storage container create `
    --name $ContainerName `
    --account-name $storageAccountName `
    --account-key $storageKey `
    --output none

$backendPath = Join-Path $PSScriptRoot "..\terraform\backend.hcl"
@(
    "resource_group_name  = `"$ResourceGroupName`""
    "storage_account_name = `"$storageAccountName`""
    "container_name       = `"$ContainerName`""
    "key                  = `"azure-monitoring-alerting-automation/$Environment.tfstate`""
) | Set-Content -Path $backendPath -Encoding utf8

Write-Host "Terraform backend configuration written to $backendPath"
Write-Host ""
Write-Host "GitHub repository variables for deploy-monitoring.yml:"
Write-Host "TF_STATE_RESOURCE_GROUP=$ResourceGroupName"
Write-Host "TF_STATE_STORAGE_ACCOUNT=$storageAccountName"
Write-Host "TF_STATE_CONTAINER=$ContainerName"
Write-Host "TF_STATE_KEY=azure-monitoring-alerting-automation/$Environment.tfstate"

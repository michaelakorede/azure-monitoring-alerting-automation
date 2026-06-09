param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubOwner,

    [Parameter(Mandatory = $true)]
    [string]$GitHubRepo,

    [string]$Environment = "dev",

    [string]$AppDisplayName = "github-monitoring-alerting",

    [string]$RoleAssignmentScope
)

$ErrorActionPreference = "Stop"

$subscriptionId = az account show --query id -o tsv
$tenantId = az account show --query tenantId -o tsv
$scope = if ($RoleAssignmentScope) { $RoleAssignmentScope } else { "/subscriptions/$subscriptionId" }
$subject = "repo:${GitHubOwner}/${GitHubRepo}:ref:refs/heads/main"
$displayName = "$AppDisplayName-$Environment"

Write-Host "Creating Microsoft Entra app registration: $displayName"
$clientId = az ad app create --display-name $displayName --query appId -o tsv
$appObjectId = az ad app show --id $clientId --query id -o tsv
az ad sp create --id $clientId | Out-Null

$federatedCredential = @{
    name        = "github-main"
    issuer      = "https://token.actions.githubusercontent.com"
    subject     = $subject
    audiences   = @("api://AzureADTokenExchange")
    description = "GitHub Actions main branch deployment for $GitHubOwner/$GitHubRepo"
} | ConvertTo-Json -Compress

az ad app federated-credential create --id $appObjectId --parameters $federatedCredential | Out-Null
az role assignment create --assignee $clientId --role Contributor --scope $scope | Out-Null

Write-Host ""
Write-Host "Create these GitHub Actions secrets:"
Write-Host "AZURE_CLIENT_ID=$clientId"
Write-Host "AZURE_TENANT_ID=$tenantId"
Write-Host "AZURE_SUBSCRIPTION_ID=$subscriptionId"
Write-Host "MONITOR_OPS_EMAIL=<operations-email>"
Write-Host ""
Write-Host "Create this GitHub Actions repository variable:"
Write-Host "MONITOR_TARGET_RESOURCE_ID=<full-resource-id-to-monitor>"


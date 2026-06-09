param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$Name
)

$ErrorActionPreference = "Stop"

if ($Name) {
    az resource list `
        --resource-group $ResourceGroupName `
        --name $Name `
        --query "[].{Name:name, Type:type, Id:id}" `
        --output table
}
else {
    az resource list `
        --resource-group $ResourceGroupName `
        --query "[].{Name:name, Type:type, Id:id}" `
        --output table
}


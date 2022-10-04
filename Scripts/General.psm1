# A library providing config and common elements for the deployment scripts
function Get_Environment_Config {
    param (
        [Parameter(Mandatory)]
        [string]$localenv
    )
    $environments = @{
        "dev" = @{
            "subscriptionID" = "7c235ed2-aade-4f4c-a9d3-78f332fb5aee"
            "subscriptionName" = "UDAL Training"
            "location" = "uksouth"
            "orgCode" = "QBX"
        }
        "prod" = @{
            "subscriptionID" = "7c235ed2-aade-4f4c-a9d3-78f332fb5aee"
            "subscriptionName" = "UDAL Training"
            "location" = "uksouth"
            "orgCode" = "QBX"
        }
    }

    return $environments.$localenv
}
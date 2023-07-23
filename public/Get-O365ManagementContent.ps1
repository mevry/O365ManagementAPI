function Get-O365ManagementContent{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$ContentUri
    )

    $requestSplat = @{
        uri = $ContentUri
        method = 'GET'
        headers = @{
            Authorization = "Bearer $access_token"
        }
    }
    #(Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json
    Invoke-WebRequest @requestSplat
}
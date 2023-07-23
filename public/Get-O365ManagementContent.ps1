function Get-O365ManagementContent{
    [cmdletbinding()]
    param(

        [parameter(Mandatory, ParameterSetName="ContentUri", ValueFromPipelineByPropertyName)]
        [string]$ContentUri
    )
    Begin{}
    Process{
        $requestSplat = @{
            uri = $ContentUri
            method = 'GET'
            headers = @{
                Authorization = "Bearer $access_token"
            }
        }
        #$requestSplat['uri']
        (Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json
    }
    End{}
}
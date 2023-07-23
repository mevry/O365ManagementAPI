function Start-O365ManagementSearch{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet("Audit.AzureActiveDirectory","Audit.Exchange","Audit.SharePoint","Audit.General","DLP.All")]
        [string]$ContentType,
        [Parameter(ParameterSetName="StartDateTimeSelected")]
        [datetime]$StartDateTime = (Get-Date).AddHours(-1),
        [Parameter(ParameterSetName="StartDateTimeSelected")]
        [datetime]$EndDateTime = (Get-Date)
    )

    $startFormatted = $StartDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss")
    $endFormatted = $EndDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss")
    $requestSplat = @{
        uri = "https://$resourceDomain/api/v1.0/$tenantId/activity/feed/subscriptions/content?contentType=$ContentType&startTime=$startFormatted&endTime=$endFormatted&PublisherIdentifier=$publisherIdentifier"
        method = 'GET'
        headers = @{
            Authorization = "Bearer $access_token"
        }
    }
    Write-Verbose "Start: $startFormatted"
    Write-Verbose "End: $endFormatted"
    #(Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json
    Invoke-WebRequest @requestSplat
}
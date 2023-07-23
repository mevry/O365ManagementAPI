function Stop-O365ManagementSubscription{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet("Audit.AzureActiveDirectory","Audit.Exchange","Audit.SharePoint","Audit.General","DLP.All")]
        [string]$ContentType
    )
    $requestSplat = @{
        uri = "https://$resourceDomain/api/v1.0/$tenantId/activity/feed/subscriptions/stop?contentType=$ContentType&PublisherIdentifier=$publisherIdentifier"
        method = 'POST'
        headers = @{
            Authorization = "Bearer $access_token"
        }
    }
    (Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json
}
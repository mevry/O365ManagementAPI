function Get-O365ManagementSubscriptions{
    $requestSplat = @{
        uri = "https://$resourceDomain/api/v1.0/$tenantId/activity/feed/subscriptions/list?PublisherIdentifier=$publisherIdentifier"
        method = 'GET'
        headers = @{
            Authorization = "Bearer $access_token"
        }
    }
    (Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json
}
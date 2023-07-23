function Connect-O365ManagementApi {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$TenantId,
        [parameter(Mandatory)]
        [string]$ApplicationId,
        [parameter(Mandatory)]
        [string]$ApplicationSecret,
        [ValidateSet("Commercial", "GCC", "GCCHigh", "DoD")]
        [string]$Environment = "Commercial",
        [string]$PublisherIdentifier = $TenantId
    )
    $Global:tenantId = $TenantId
    $Global:appId = $ApplicationId
    $Global:publisherIdentifer = $PublisherIdentifier

    #https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-reference#activity-api-operations
    switch ($Environment) {
        "Commercial" { $Global:loginDomain = "login.microsoftonline.com"; $Global:resourceDomain = "manage.office.com" }
        "GCC" { $Global:loginDomain = "login.microsoftonline.com"; $Global:resourceDomain = "manage-gcc.office.com" }
        "GCCHigh" { $Global:loginDomain = "login.microsoftonline.us"; $Global:resourceDomain = "manage.office365.us" }
        "DoD" {$Global:loginDomain = "login.microsoftonline.us"; $Global:resourceDomain = "manage.protection.apps.mil"}
        Default {}
    }
    $requestSplat = @{
        uri = "https://$loginDomain/$tenantId/oauth2/token"
        method = 'POST'
        body = @{
            resource = "https://$resourceDomain"
            client_id= $appId
            grant_type = "client_credentials"
            #client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
            client_secret = $ApplicationSecret
        }
    }
    $Global:access_token = ((Invoke-WebRequest @requestSplat).Content | ConvertFrom-Json).access_token
}
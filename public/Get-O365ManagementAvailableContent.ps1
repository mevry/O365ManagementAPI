function Get-O365ManagementAvailableContent{
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ParameterSetName="Default")]
        [ValidateSet("Audit.AzureActiveDirectory","Audit.Exchange","Audit.SharePoint","Audit.General","DLP.All")]
        [string]$ContentType,
        [Parameter(ParameterSetName="Default")]
        [datetime]$StartDateTime = (Get-Date).AddHours(-1),
        [Parameter(ParameterSetName="Default")]
        [datetime]$EndDateTime = (Get-Date),
        [Parameter(ParameterSetName="Uri")]
        [string]$Uri
    )

    #Check if subscription is enabled.
    if(-not (Get-O365ManagementSubscriptions | Where-Object {$_.ContentType -eq $ContentType}).status -eq "enabled"){
        throw "$ContentType not enabled. Use 'Start-O365ManagementSubscription -ContentType $ContentType' to enable."
    }
    
    #If provided, convert datetimes to UTC and format to specifications.
    if($StartDateTime){$startFormatted = $StartDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss")}
    if($EndDateTime){$endFormatted = $EndDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss")}

    $requestSplat = @{
        #Use specified URI if none was provided as a parameter.
        uri = ($Uri ? $Uri : "https://$resourceDomain/api/v1.0/$tenantId/activity/feed/subscriptions/content?contentType=$ContentType&startTime=$startFormatted&endTime=$endFormatted&PublisherIdentifier=$publisherIdentifier")
        method = 'GET'
        headers = @{
            Authorization = "Bearer $access_token"
        }
    }
    Write-Verbose "URI: $Uri"
    Write-Verbose "Start: $startFormatted"
    Write-Verbose "End: $endFormatted"
    $response = Invoke-WebRequest @requestSplat
    foreach($contentBlob in ($response.Content | ConvertFrom-Json)){
        $contentBlob
    }
    if($response.Headers['NextPageUri']){
        Start-O365ManagementSearch -Uri $response.Header['NextPageUri']
    }
}
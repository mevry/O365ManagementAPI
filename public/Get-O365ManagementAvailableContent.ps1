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
    $dateDiff = $EndDateTime - $StartDateTime
    if ($dateDiff -lt 0) {throw "StartDateTime must be before EndDateTime."}

    #The API requires no larger than a 24 hour window be specified
    #Running two Get-Dates can result in a time that is greater than 24 hours
    #if you use the DateTime Add methods.
    #This shifts the STARTDATETIME forward within that window.
    $oneDayLimit = New-TimeSpan -Days 1
    if ($dateDiff -gt $oneDayLimit){
        $timeShift = $dateDiff - $oneDayLimit
        if($timeShift -gt (New-TimeSpan -Seconds 1)){
            Write-Host -ForegroundColor Yellow "[WARN] " -NoNewline; Write-Host "Specified interval is greater than the maximum of 24 hours. Shifting StartDateTime forward $timeShift."
        }
        $StartDateTime = $StartDateTime + $timeShift
    }

    function Test-SubscriptionEnabled {
        param($ContentType)
        (Get-O365ManagementSubscriptions | Where-Object {$_.ContentType -eq $ContentType}).status -eq "enabled"
    }

    #Check if subscription is enabled.
    if(
        ($PSCmdlet.ParameterSetName -ne "Uri") `
        -and -not (Test-SubscriptionEnabled -ContentType $ContentType)
    ){
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
        Write-Verbose "Paging: $($response.Headers['NextPageUri'])"
        #PowerShell throwing error when referencing NextPageUri directly in -Uri parameter
        #Using variable and casting as string as workaround
        $nextPageUri = $response.Headers['NextPageUri']
        Get-O365ManagementAvailableContent -Uri ([string]$nextPageUri)
    }
}
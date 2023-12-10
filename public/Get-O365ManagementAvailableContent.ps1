<#
.SYNOPSIS
Lists content blobs (containers for logs) that are available to retrieve for the requested time frame.

.DESCRIPTION
Lists content blobs (containers for logs) that are available to retrieve for the requested time frame. Content blobs should be passed to Get-O365ManagementContent to retrieve the actual logs.

.PARAMETER ContentType
Choose an audit log type. Only one is supported at this time. Valid types are: Audit.AzureActiveDirectory, Audit.Exchange, Audit.SharePoint, Audit.General, DLP.All

.PARAMETER StartDateTime
The start of the requested time. May not be more than 7 days ago. Also, the API is not always precise in the time it retrieves.

.PARAMETER EndDateTime
The end of the requested time. This must be no more than 24 hours after the StartDateTime.

.PARAMETER Uri
Called internally. Only used to retrieve the next page of content blobs. Future releases will hide this parameter.

.EXAMPLE 
$contentBlob = Get-O365ManagementAvailableContent -ContentType Audit.AzureActiveDirectory
#Retrieve content blob for last hour of AAD Audit logs.

#>
function Get-O365ManagementAvailableContent{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, ParameterSetName="Default")]
        [ValidateSet("Audit.AzureActiveDirectory","Audit.Exchange","Audit.SharePoint","Audit.General","DLP.All")]
        [string]$ContentType,
        [Parameter(ParameterSetName="Default")]
        [datetime]$StartDateTime = (Get-Date).AddHours(-1),
        [Parameter(ParameterSetName="Default")]
        [datetime]$EndDateTime = (Get-Date),
        [Parameter(Mandatory=$true, ParameterSetName="Uri")]
        [string]$Uri
    )
    $dateDiff = $EndDateTime - $StartDateTime
    if ($dateDiff -lt 0) {throw "StartDateTime must be before EndDateTime."}

    $sevenDaysPastLimit = (Get-Date).AddDays(-7)
    if ($StartDateTime -lt $sevenDaysPastLimit){
        Write-Host -ForegroundColor Yellow "[WARN] " -NoNewline; Write-Host "Specified start date is more than 7 days in the past, shifting the start date to $sevenDaysPastLimit."
        $StartDateTime = $sevenDaysPastLimit
    }

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
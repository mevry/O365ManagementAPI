function Export-O365ManagementContent{
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        [ContentBlob]$ContentBlob,
        [string]$ExportDirectory = (Get-Location),
        [string]$Filename
    )
    Begin{      
    }
    Process{
        if(-not $Filename){
            $s = ($_.ContentId).split('$') 
            $file = "$($s[3])_$($s[1])_$($s[4]).json"
        }
        Write-Verbose "Filename: $file"
        $requestSplat = @{
            uri = $_.ContentUri
            method = 'GET'
            headers = @{
                Authorization = "Bearer $access_token"
            }
        }

        Write-Verbose "Requesting: $($_.ContentUri)"
        (Invoke-WebRequest @requestSplat).Content | Out-File -FilePath "$ExportDirectory$([IO.Path]::DirectorySeparatorChar)$file"
    }
    End{}
}
using module ".\classes\ContentBlob.psm1"

#List of files to be dot sourced.
$dotSource = Get-ChildItem -Include "*.ps1" -Recurse -Path @("$PSScriptRoot\private","$PSScriptRoot\public")

#Dot source each file.
foreach($file in $dotSource){
    try{
        . $file.FullName
    }
    catch{
        Write-Error -Message "Failed to import $($file.FullName): $($error[0].Exception.Message)"
    }
}
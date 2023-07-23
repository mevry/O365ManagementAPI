function Disconnect-O365ManagementApi {
    [cmdletbinding()]
    param()

    Remove-Variable Global:tenantId
    Remove-Variable Global:appId
    Remove-Variable Global:access_token
    Remove-Variable Global:publisherIdentifer

}
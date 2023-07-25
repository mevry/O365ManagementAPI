function Disconnect-O365ManagementApi {
    [cmdletbinding()]
    param()

    Remove-Variable -Scope Global -Name tenantId
    Remove-Variable -Scope Global -Name appId
    Remove-Variable -Scope Global -Name access_token
    Remove-Variable -Scope Global -Name publisherIdentifer

}
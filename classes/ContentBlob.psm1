class ContentBlob
{

    [ValidateNotNullOrEmpty()]
    [string]$ContentUri
    [ValidateNotNullOrEmpty()]
    [string]$ContentId
    [ValidateNotNullOrEmpty()]
    [string]$ContentType
    [datetime]$ContentCreated
    [datetime]$ContentExpiration

    Contact(
        [string]$ContentUri,
        [string]$ContentId,
        [string]$ContentType,
        [datetime]$ContentCreated,
        [datetime]$ContentExpiration
    ) {
       $this.ContentUri = $ContentUri
       $this.ContentId = $ContentId
       $this.ContentType = $ContentType
       $this.ContentCreated = $ContentCreated
       $this.ContentUri = $ContentUri
    }
}
Function Get-AzStorageContainerSASUri {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$TenantId,

        [Parameter(Mandatory=$true)]
        [String]$ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [String]$StorageAccountName,

        [Parameter(Mandatory=$true)]
        [String]$ContainerName,

        [Parameter(Mandatory=$false)]
        [Int]$TokenDurationMinutes = 15,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Connect as Service Principal
    Connect-AzAccount -TenantId $TenantId -Credential $Credential -ServicePrincipal -WarningAction 'SilentlyContinue' | Out-Null

    # Load the Storage Account context
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName)[0].Value
    $StorageContext    = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    # Generate a full URI to the container with SAS token
    $SasParam = @{
        Context    = $StorageContext
        Name 	     = $ContainerName
        ExpiryTime = (Get-Date).AddMinutes($TokenDurationMinutes)
        Permission = 'rw'
        FullUri    = $true
    }
    
    $Uri = New-AzStorageContainerSASToken @SasParam
    Return $Uri
}

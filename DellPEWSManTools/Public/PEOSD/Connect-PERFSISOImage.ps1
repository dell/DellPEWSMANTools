
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER IPAddress
Parameter description

.PARAMETER ShareName
Parameter description

.PARAMETER ImageName
Parameter description

.PARAMETER Credential
Parameter description

.PARAMETER ShareType
Parameter description

.PARAMETER HashType
Parameter description

.PARAMETER HashValue
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Connect-PERFSISOImage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
        
        [Parameter(Mandatory)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String]$ShareName,

        [Parameter(Mandatory)]
        [String]$ImageName,

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter()]
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",
        
        [Parameter(Mandatory)]
        [ValidateSet('MD5','SHA1')]
        [String] $HashType,

        [Parameter(Mandatory)]
        [String] $HashValue
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        $params= @{
            IPAddress = $IPAddress
            ShareName = $ShareName
            ShareType = ([ShareType]$ShareType -as [int])
            ImageName = $ImageName
            Username = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
            HashType = ([HashType]$HashType -as [int])
            HashValue = $HashValue
        }

        Invoke-CimMethod -InputObject $instance -CimSession $iDRACSession -MethodName ConnectRFSISOImage -Arguments $params
    }
}
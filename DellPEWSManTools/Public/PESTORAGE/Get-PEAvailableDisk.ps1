<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER DiskType
Parameter description

.PARAMETER DiskProtocol
Parameter description

.PARAMETER DiskEncrypt
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEAvailableDisk
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        $DiskType,

        [Parameter()]
        $DiskProtocol,

        [Parameter()]
        $DiskEncrypt
    )

    Process 
    {
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_PhysicalDiskView -Namespace 'root/dcim'
    }
}

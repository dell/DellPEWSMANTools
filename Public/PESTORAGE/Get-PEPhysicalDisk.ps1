<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER MediaType
Parameter description

.PARAMETER BusProtocol
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEPhysicalDisk
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [ValidateSet('HDD','SSD')]
        $MediaType,

        [Parameter()]
        [ValidateSet('Unknown','SCSI','PATA','FIBRE','USB','SATA','SAS','PCIe')]
        $BusProtocol
    )
    Process {
        if ($MediaType -and $BusProtocol)
        {
            $mediaInt = [int]([Disk.MediaType]$MediaType)
            $busProtocolInt = [int]([Disk.BusProtocol]$BusProtocol)
            $filter = "MediaType=$mediaInt AND BusProtocol=$BusProtocolInt"
        }
        elseif ($MediaType)
        {
            $mediaInt = [int]([Disk.MediaType]$MediaType)          
            $filter = "MediaType=$mediaInt"
        }
        elseif ($BusProtocol)
        {
            $busProtocolInt = [int]([Disk.BusProtocol]$BusProtocol)            
            $filter = "BusProtocol=$BusProtocolInt"
        }
        else
        {
            $filter = $null
        }

        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_PhysicalDiskView -Namespace 'root/dcim' -Filter $filter
    }
}
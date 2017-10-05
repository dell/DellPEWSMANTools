<#
Get-PEPhysicalDisk.ps1 - Get PE physical disk information.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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
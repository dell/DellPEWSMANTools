<#
Get-PENetworkDeviceStatistic.ps1 - Gets network device statistics from PE server.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Get-PENetworkDeviceStatistic
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $FQDD
    )

    Process 
    {
        Write-Verbose "Getting Network device statistics for $($iDRACSession.ComputerName) ..."
        
        if ($FQDD)
        {
            $filter = "FQDD='$FQDD'"
        }
        else
        {
            $filter = $null
        }
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_NICStatistics -Namespace root\dcim -Filter $filter
    
    }
}
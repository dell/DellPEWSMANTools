<#
Get-PESoftwareInventory.ps1 - GET PE Software inventory.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function  Get-PESoftwareInventory
{
    [CmdletBinding(DefaultParameterSetName='General')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Installed')]
        [Parameter(Mandatory, ParameterSetName='Available')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession,

        [Parameter(ParameterSetName='Installed')]
        [Switch] $Installed,

        [Parameter(ParameterSetName='Available')]
        [Switch] $Available
    )

    Process
    {
        if ($Available)
        {
            Write-Verbose "Getting available Software Inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Available'" -Namespace "root/dcim"
        }
        elseif ($Installed)
        {
            Write-Verbose "Getting installed software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Installed'" -Namespace "root/dcim"
        }
        else
        {
            Write-Verbose "Getting software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Namespace "root/dcim"
        }
    }
}
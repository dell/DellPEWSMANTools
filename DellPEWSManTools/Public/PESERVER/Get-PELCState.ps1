<#
Get-PELCState.ps1 - GET PE LC state.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Get-PELCState
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    ) 
       
    Begin
    {

    }

    Process
    {
        Write-Verbose "Retrieving PE LC state information ..."
        try
        {
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim -Filter "AttributeName='Lifecycle Controller State'"
        }
        catch
        {
            Write-Error -Message $_
        }
    }

    End
    {

    }
}

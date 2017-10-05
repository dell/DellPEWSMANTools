<#
Set-PEPowerState.ps1 - Sets PE system power state.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PEPowerState
{
    [CmdletBinding(
                SupportsShouldProcess=$true,
                ConfirmImpact="High",
                DefaultParameterSetName='General'
    )]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ParameterSetName='Passthru')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet("PowerOn","PowerOff","PowerCycle")]
        [String] $State = 'PowerOn',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Force,
        
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin 
    {
        $properties=@{CreationClassName="DCIM_ComputerSystem";Name="srv:system";}
        $instance = New-CimInstance -ClassName DCIM_ComputerSystem -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }
    }

    Process 
    {
        if ($pscmdlet.ShouldProcess($iDRACSession.ComputerName, $State))
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName RequestStateChange -CimSession $iDRACSession -Arguments @{'RequestedState'= [PowerState]$State -as [int]}
            if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
            {
                $job
            }
        }
        
    }
}
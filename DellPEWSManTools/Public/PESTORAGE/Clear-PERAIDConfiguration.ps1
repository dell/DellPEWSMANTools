<#
Clear-PERAIDConfiguration.ps1 - Clear PE RAID configuration on the controller.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Clear-PERAIDConfiguration 
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High",
        DefaultParameterSetName='General'
    )]

    param (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Passthru')]
        [Parameter(Mandatory, ParameterSetName='Wait')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        $InstanceID,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('None','PowerCycle','Graceful','Forced')]
        $RebootType = 'None',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $StartTime = 'TIME_NOW',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $UntilTime,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Switch] $Force,

        [Parameter(ParameterSetName='Wait')]
        [Switch] $Wait,

        [Parameter(ParameterSetName='Passthru')]
        [Switch] $Passthru
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }
    }

    Process 
    {
        if ($PSCmdlet.ShouldProcess($InstanceID, 'Clear Configuration')) 
        {
            $output = Invoke-CimMethod -InputObject $instance -MethodName ResetConfig -CimSession $idracsession -Arguments @{'Target'=$InstanceID}
            if ($output.ReturnValue -eq 0) 
            {
                if ($Output.RebootRequired -eq 'Yes') {
                    $RebootRequired = $true
                    if ($RebootType -eq 'None') 
                    {
                        Write-Warning 'A job will be scheduled but a reboot is required to complete the task. However, reboot type has been set to None. Manually power Cycle the target system to complete this job.'
                    } 
                    else 
                    {
                        Write-Warning "A job will be scheduled and a system reboot ($RebootType) will be initiated to complete the task"
                    }
                }
                else 
                {
                    $RebootRequired = $false
                    if ($RebootType -ne 'None') 
                    {
                        Write-Warning "System reboot is not required to complete the task. However, Reboot type is set to $RebootType. A reboot will be initiated to complete the task"
                    }
                }
            
                if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired -Passthru
                } 
                elseif ($PSCmdlet.ParameterSetName -eq 'Wait') 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired -Wait
                } 
                else 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired
                }
            }
            else 
            {
                $output
            }
        }
    }
}

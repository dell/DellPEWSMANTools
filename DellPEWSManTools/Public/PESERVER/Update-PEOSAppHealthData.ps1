<#
Update-PEOSAppHealthData.ps1 - Update PE system OS and application health data.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Update-PEOSAppHealthData
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Alias("s")]
        [Parameter(Mandatory,
                   ParameterSetName='Passthru')]
        [Parameter(Mandatory,
                   ParameterSetName='Wait')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('AgentLiteOSPlugin','Manual')]
        [String]$UpdateType = 'AgentLiteOSPlugin',
        
        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [switch]$Wait,

        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $Parameters = @{
            UpdateType = [OSAPPUpdateType]$UpdateType -as [int]
        }
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Update OS App health data'))
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName UpdateOSAppHealthData -CimSession $iDRACSession -Arguments $Parameters
            if ($job.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $job
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -JobID $job.Job.EndpointReference.InstanceID -iDRACSession $iDRACSession -Activity 'Updating OS APP Health Data'
                }
            } 
            else 
            {
                Throw "Job creation failed with an error: $($job.Message)"
            }
        }
    }
}

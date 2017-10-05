<#
New-PERebootJobForSWUpdate.ps1 - New PE system reboot for software update.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function New-PERebootJobForSWUpdate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false,
                  SupportsShouldProcess=$true,
                  ConfirmImpact='low')]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet('PowerCycle','Graceful','Forced')]
        $RebootType = 'PowerCycle',

        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="IDRAC:ID";CreationClassName="DCIM_SoftwareInstallationService";Name="SoftwareUpdate";}
        $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        $params=@{}
        $params.Add('RebootJobType',([ConfigJobRebootType]$RebootType -as [int]))
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Create new reboot job for software update'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName CreateRebootJob -CimSession $iDRACSession -Arguments $params #2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.RebootJobID.EndpointReference.InstanceID -Activity "Rebooting for Software Update for $($iDRACSession.ComputerName)"
                    Write-Verbose "Reboot for Software Update done seccessfully"
                }
            } 
            else 
            {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }
        }
    }
}
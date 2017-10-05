<#
New-PESystemRebootJob.ps1 - New PE system reboot job.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function New-PESystemRebootJob
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateSet(1,2,3)]
        [String] $RebootJobType
    
    )

    Process 
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'create new system reboot job'))
        {
            $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_SoftwareInstallationService";Name="DCIM:SoftwareUpdate";}
            $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
                
            $Parameters = @{
                RebootJobType = $RebootJobType
            }

            Invoke-CimMethod -InputObject $instance -MethodName CreateRebootJob -CimSession $iDRACSession -Arguments $Parameters
        }
    }
}

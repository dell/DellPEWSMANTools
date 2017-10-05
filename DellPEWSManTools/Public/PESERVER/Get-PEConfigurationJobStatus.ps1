<#
Get-PEConfigurationJobStatus.ps1 - GET PE configuration job status.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Get-PEConfigurationJobStatus 
{
    [CmdletBinding(DefaultParameterSetName='General')]
    param (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   ParameterSetName='Wait')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory,
                    ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [String]$JobID,

        [Parameter(ParameterSetName='Wait')]
        [Switch]$Wait
    )

    Process
    {
        try 
        {
            #$job = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT * FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
            $job = Get-CimInstance -CimSession $iDRACSession -Namespace "root/dcim" -ClassName DCIM_LifecycleJob -Filter "InstanceID='$JobID'" -ErrorAction Stop
            if ($job) 
            {
                if ($Wait) 
                {
                    Wait-PEConfigurationJob -JobID $JobID -iDRACSession $iDRACSession -Activity 'Waiting for Job ...'
                } 
                else 
                {
                    $job
                }
            }
        }
        catch 
        {
            Write-Error $_            
        }
    }
}
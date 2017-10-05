<#
New-PEJobQueue.ps1 - New PE job queue.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function New-PEJobQueue 
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='low')]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        [string]$JobID,

        [Parameter()]
        [string]$StartTimeInterval ='TIME_NOW',

        [Parameter()]
        [string]$UntilTime
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="Idrac";CreationClassName="DCIM_JobService";Name="JobService";}
        $instance = New-CimInstance -ClassName DCIM_JobService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        $Parameters = @{
            JobArray = $JobID
            StartTimeInterval = $StartTimeInterval
        }

        if ($UntilTime) 
        {
            $Parameters.Add('UntilTime',$UntilTime)
        }
    }

    Process 
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Create job queue'))
        {
            $Job = Invoke-CimMethod -InputObject $instance -MethodName SetupJobQueue -CimSession $idracsession -Arguments $Parameters
            $Job
            #if ($Job.ReturnValue -eq 0) {
            #    Write-Verbose "New job created with an ID - $($Job.Job.EndpointReference.InstanceID)"
            #} else {
            #    $Job
            #}
        }
        
    }
}

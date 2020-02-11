<#
Wait-PEConfigurationJob.ps1 - Wait for PE configuration job to complete.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Wait-PEConfigurationJob
{
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
    
        [Parameter (Mandatory)]
        $JobID,

        [Parameter()]
        [String]$Activity = 'Performing iDRAC job'
    )
    
    $jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
    #$jobstatus = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LifecycleJob -Namespace 'root/dcim' -Filter "InstanceID='$JobID'" -Property InstanceID,JobStatus,Message,PercentComplete
    if ($jobstatus.PercentComplete -eq 'NA') 
    {
        $PercentComplete = 0
    } 
    else 
    {
        $PercentComplete = $JobStatus.PercentComplete
    }
    
    while (($jobstatus.JobStatus -like 'Running') -or ($jobstatus.JobStatus -like '*Progress*') -or 
        ($jobstatus.JobStatus -like '*ready*') -or ($jobstatus.JobStatus -like '*pending*') -or 
        ($jobstatus.JobStatus -like '*downloading*'))
    {
        $jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
        #$jobstatus = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LifecycleJob -Namespace 'root/dcim' -Filter "InstanceID='$JobID'" -Property InstanceID,JobStatus,Message,PercentComplete
        if ($jobstatus.JobStatus -notlike '*Failed*') 
        {
            if ($jobstatus.PercentComplete -eq 'NA') 
            {
                $PercentComplete = 0
            } 
            else 
            {
                $PercentComplete = $JobStatus.PercentComplete
            }
        } 
        else 
        {
            Throw "Job creation failed with an error: $($jobstatus.Message). Use 'Get-PEConfigurationResult -JobID $($jobstatus.Job.EndpointReference.InstanceID)' to receive detailed configuration result"
        }
        
        Write-Progress -activity "Job Status: $($JobStatus.Message)" -status "$PercentComplete % Complete:" -percentcomplete $PercentComplete
        Start-Sleep 1
    }
}
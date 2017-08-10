<#
.Synopsis
   This cmdlets provides the progress of a job object and waits till it is complete
.DESCRIPTION
   This cmdlets provides the progress of a job object and waits till it is complete
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Wait-PEConfigurationJob -JobID 'JobID String'
.EXAMPLE
   The following example creates an iDRAC session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Wait-PEConfigurationJob -JobID 'JobID String' -iDRACSession $iDRACSession
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
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
    
    #$jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
    $jobstatus = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LifecycleJob -Namespace 'root/dcim' -Filter "InstanceID='$JobID'" -Property InstanceID,JobStatus,Message,PercentComplete
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
        #$jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
        $jobstatus = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LifecycleJob -Namespace 'root/dcim' -Filter "InstanceID='$JobID'" -Property InstanceID,JobStatus,Message,PercentComplete
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
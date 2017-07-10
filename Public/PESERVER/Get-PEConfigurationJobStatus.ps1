<#
.Synopsis
   This cmdlets gets the configuration job status
.DESCRIPTION
   This cmdlets gets the configuration job status and optionally waits for the job to complete
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Get-PEConfigurationJobStatus -JobID 'JobID String'
.EXAMPLE
   The following example gets the job status from a specified iDRAC Session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationJobStatus -JobID 'JobID String' -iDRACSession $iDRACSession
.EXAMPLE
   The following example waits for the job to complete
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationJobStatus -JobID 'JobID String' -iDRACSession $iDRACSession -Wait
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
    Wait - Wait for the job to complete
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
            $job = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT * FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
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
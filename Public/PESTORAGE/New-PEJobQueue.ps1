<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER JobID
Parameter description

.PARAMETER StartTimeInterval
Parameter description

.PARAMETER UntilTime
Parameter description

.EXAMPLE
An example

.NOTES
General notes
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

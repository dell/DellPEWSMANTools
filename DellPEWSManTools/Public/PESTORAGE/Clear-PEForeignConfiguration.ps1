<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER InstanceID
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Clear-PEForeignConfiguration 
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        $InstanceID
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
    }

    Process 
    {
        Invoke-CimMethod -InputObject $instance -MethodName ClearForeignConfig -CimSession $idracsession -Arguments @{'Target'=$InstanceID}
        New-PETargetedConfigurationJob -InstanceID $InstanceID -iDRACSession $iDRACSession
    }
}
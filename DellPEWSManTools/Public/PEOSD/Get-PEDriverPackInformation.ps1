<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEDriverPackInformation {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Begin {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process {
        $result = Invoke-CimMethod -InputObject $instance -MethodName GetDriverPackInfo -CimSession $iDRACSession
        if ($result.ReturnValue -ne 0) 
        {
            Write-Error $result.Message
        } 
        else 
        {
            $result
        }
    }
}
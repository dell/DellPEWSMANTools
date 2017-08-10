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
function Set-PEBootToHD
{
    [CmdletBinding(SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession    
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set Boot to HD'))
        {
            $result = Invoke-CimMethod -InputObject $instance -MethodName BootToHD -CimSession $iDRACSession
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
}
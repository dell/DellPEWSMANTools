<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER RebootJobType
Parameter description

.EXAMPLE
An example

.NOTES
General notes
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

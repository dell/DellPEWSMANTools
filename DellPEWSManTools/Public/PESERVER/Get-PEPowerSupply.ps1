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
function Get-PEPowerSupply
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process
    {
        $powerSupply = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_PowerSupplyView -Namespace root\dcim
        return $powerSupply
    }
}
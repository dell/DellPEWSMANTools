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
function Get-PEPCIeSSDExtender
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process 
    {
        $ssdExtender = Get-CimInstance -ClassName DCIM_PCIeSSDExtenderView -Namespace root\dcim -CimSession $idracsession -Verbose
        return $ssdExtender
    }
}
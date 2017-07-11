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
Function Get-PEStorageController
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
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_ControllerView' -Namespace 'root/dcim'
    }
}
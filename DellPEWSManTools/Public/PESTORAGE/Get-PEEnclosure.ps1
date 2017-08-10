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
Function Get-PEEnclosure 
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
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_EnclosureView -Namespace 'root/dcim'
    }
}
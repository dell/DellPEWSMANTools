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
function Get-PEMemory
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
        Write-Verbose "Getting System Information for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_MemoryView -Namespace "root/dcim"
    }
}
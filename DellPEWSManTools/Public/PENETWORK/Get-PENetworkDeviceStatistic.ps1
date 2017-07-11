<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER FQDD
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PENetworkDeviceStatistic
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $FQDD
    )

    Process 
    {
        Write-Verbose "Getting Network device statistics for $($iDRACSession.ComputerName) ..."
        
        if ($FQDD)
        {
            $filter = "FQDD='$FQDD'"
        }
        else
        {
            $filter = $null
        }
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_NICStatistics -Namespace root\dcim -Filter $filter
    
    }
}
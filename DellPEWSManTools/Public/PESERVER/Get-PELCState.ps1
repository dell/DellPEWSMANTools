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
function Get-PELCState
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
       
    Begin
    {

    }

    Process
    {
        Write-Verbose "Retrieving PE LC state information ..."
        try
        {
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim -Filter "AttributeName='Lifecycle Controller State'"
        }
        catch
        {
            Write-Error -Message $_
        }
    }

    End
    {

    }
}

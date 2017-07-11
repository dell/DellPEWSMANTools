<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER Installed
Parameter description

.PARAMETER Available
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function  Get-PESoftwareInventory
{
    [CmdletBinding(DefaultParameterSetName='General')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Installed')]
        [Parameter(Mandatory, ParameterSetName='Available')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession,

        [Parameter(ParameterSetName='Installed')]
        [Switch] $Installed,

        [Parameter(ParameterSetName='Available')]
        [Switch] $Available
    )

    Process
    {
        if ($Available)
        {
            Write-Verbose "Getting available Software Inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Available'" -Namespace "root/dcim"
        }
        elseif ($Installed)
        {
            Write-Verbose "Getting installed software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Installed'" -Namespace "root/dcim"
        }
        else
        {
            Write-Verbose "Getting software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Namespace "root/dcim"
        }
    }
}
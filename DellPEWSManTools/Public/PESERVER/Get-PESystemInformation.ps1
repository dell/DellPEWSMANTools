<#
.Synopsis
   Gets PowerEdge Server system information using iDRAC WSMAN interfaces
.DESCRIPTION
   Gets PowerEdge Server system information using iDRAC WSMAN interfaces
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   
   Get-PESystemInformation
.EXAMPLE
   The following example creates an iDRAC session and 
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PESystemInformation -iDRACSession $iDRACSession
.INPUTS
   iDRACSession - CIM session with an iDRAC
.OUTPUTS
   Microsoft.Management.Infrastructure.CimInstance
#>
function Get-PESystemInformation
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
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SystemView -Namespace "root/dcim"
    
    }
}
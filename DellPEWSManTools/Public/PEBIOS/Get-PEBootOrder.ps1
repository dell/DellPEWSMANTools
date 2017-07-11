function Get-PEBootOrder
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
        Write-Verbose -Message "Getting boot order for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_BootSourceSetting' -Namespace 'root/dcim'
    }
}

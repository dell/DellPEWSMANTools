function Get-PEDRACInformation
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
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PEDRAC information ..."
        try
        {
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_iDRACCardView -Namespace root\dcim
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
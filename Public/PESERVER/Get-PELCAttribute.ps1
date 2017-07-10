<#
.SYNOPSIS
This function gets a Lifecycle Controller attribute.

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER AttributeName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PELCAttribute
{
    [CmdletBinding(DefaultParameterSetName='All')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='All')]
        [Parameter(Mandatory,
                   ParameterSetName='Named')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory=$true,ParameterSetName='Named')]
        [String] $AttributeName
    ) 
       
    Begin
    {
        # Commenting this out, not being used
        # $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PE Lifecycle Controller attribute information ..."
        try
        {
            if ($psCmdlet.ParameterSetName -eq 'Named')
            {
                Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim -Filter "AttributeName='$AttributeName'"
            }
            else
            {
                Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim
            }
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
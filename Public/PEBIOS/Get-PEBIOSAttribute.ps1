function Get-PEBIOSAttribute
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
        [String] $AttributeDisplayName,

        [Parameter()]
        [String] $AttributeName,

        [Parameter()]
        [String] $GroupDisplayName
    ) 

    Begin
    {
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PEBIOS attribute information ..."
        try
        {
            if ($AttributeDisplayName -and $AttributeName)
            {
                Write-Warning -Message 'Both AttributeName and AttributeDisplayName are specified. Only either of them will be used in the filter.'
            }

            if ($AttributeName -and $GroupDisplayName)
            {
                $filter = "AttributeName='$AttributeName' AND GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($AttributeName)
            {
                $filter = "AttributeName='$AttributeName'"
            }
            elseif ($AttributeDisplayName -and $GroupDisplayName)
            {

                $filter = "AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($GroupDisplayName)
            {
                $filter = "GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($AttributeDisplayName)
            {
                $filter = "AttributeDisplayName='$AttributeDisplayName'"
            }
            else
            {
                $filter = $null
            }

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_BIOSEnumeration -Namespace root\dcim -Filter $filter
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

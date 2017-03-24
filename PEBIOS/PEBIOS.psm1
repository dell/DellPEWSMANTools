<#
.Synopsis
   Gets the boot order of a PowerEdge Server system.
.DESCRIPTION
   This cmdlet can be used to get the boot order a PowerEdge Server System. The boot sequence is displayed in the order of current assigned sequence.
.EXAMPLE
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBootOrder -iDRACSession $iDRACSession
.INPUTS
   iDRACSession - CIM session with an iDRAC
.OUTPUTS
    
#>
function Get-PEBootOrder
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        [Alias("s")]
        $iDRACSession
    )
    
    Process
    {
        foreach ($session in $iDRACSession) 
        {
            Write-Verbose -Message "Getting boot order for $($session.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_BootSourceSetting' -Namespace 'root/dcim'
        }
    }
}

function Get-PEBIOSAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
                   )]
        [Alias("s")]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeDisplayName,

        [Parameter()]
        [String] $GroupDisplayName
    ) 

    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PEBIOS attribute information ..."
        try
        {
            if ($AttributeDisplayName -and $GroupDisplayName)
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

Export-ModuleMember -Function *
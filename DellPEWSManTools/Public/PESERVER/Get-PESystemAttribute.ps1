<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER AttributeDisplayName
Parameter description

.PARAMETER GroupDisplayName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PESystemAttribute
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
        [String] $GroupDisplayName
    ) 
       
    Begin
    {
        
    }

    Process
    {
        Write-Verbose "Retrieving PE Systme attribute information ..."
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

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SystemEnumeration -Namespace root\dcim -Filter $filter
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

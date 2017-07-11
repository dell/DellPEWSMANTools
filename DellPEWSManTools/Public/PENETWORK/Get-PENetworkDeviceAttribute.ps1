<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER FQDD
Parameter description

.PARAMETER GroupDisplayName
Parameter description

.PARAMETER AttributeDisplayName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PENetworkDeviceAttribute
{
    [CmdletBinding(DefaultParameterSetName='All')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]  
        $iDRACSession,

        [Parameter()]
        [String] $FQDD,

        [Parameter()]
        [String] $GroupDisplayName,

        [Parameter()]
        [String] $AttributeDisplayName
    )

    Process 
    {
            Write-Verbose "Getting Network device attributes for $($iDRACSession.ComputerName) ..."
            
            if ($FQDD)
            {
                if ($AttributeDisplayName -and $GroupDisplayName)
                {
                    $filter = "FQDD='$FQDD' AND AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
                }
                elseif ($AttributeDisplayName)
                {
                    $filter = "FQDD='$FQDD' AND AttributeDisplayName='$AttributeDisplayName'"
                }
                elseif ($GroupDisplayName)
                {
                    $filter = "FQDD='$FQDD' AND GroupDisplayName='$GroupDisplayName'"
                }
                else
                {
                    $filter = "FQDD='$FQDD'"
                }
            }
            elseif ($AttributeDisplayName)
            {
                if ($FQDD -and $GroupDisplayName)
                {
                    $filter = "FQDD='$FQDD' AND AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
                }
                elseif ($FQDD)
                {
                    $filter = "FQDD='$FQDD' AND AttributeDisplayName='$AttributeDisplayName'"
                }
                elseif ($GroupDisplayName)
                {
                    $filter = "AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
                }
                else
                {
                    $filter = "AttributeDisplayName='$AttributeDisplayName'"
                }
            }
            elseif ($GroupDisplayName)
            {
                if ($FQDD -and $AttributeDisplayName)
                {
                    $filter = "FQDD='$FQDD' AND AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
                }
                elseif ($AttributeDisplayName)
                {
                    $filter = "GroupDisplayName='$GroupDisplayName' AND AttributeDisplayName='$AttributeDisplayName'"
                }
                elseif ($FQDD)
                {
                    $filter = "FQDD='$FQDD' AND GroupDisplayName='$GroupDisplayName'"
                }
                else
                {
                    $filter = "GroupDisplayName='$GroupDisplayName'"
                }
            }
            else
            {
                $filter = $null
            }
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_NICEnumeration -Namespace root\dcim -Filter $filter
    }
}

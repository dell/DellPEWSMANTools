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
function Get-PENetworkDevice
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
        Write-Verbose "Getting Network device Information for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -ResourceUri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_NICView' -Namespace root\dcim -CimSession $iDRACSession
    }
}

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

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER FQDD
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PENetworkDeviceCapability
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
        [String] $FQDD
    )

    Process 
    {
        Write-Verbose "Getting Network device capabilities for $($iDRACSession.ComputerName) ..."
        
        if ($FQDD)
        {
            $filter = "FQDD='$FQDD'"
        }
        else
        {
            $filter = $null
        }
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_NICCapabilities -Namespace root\dcim -Filter $filter
    
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER FQDD
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PENetworkDeviceStatistic
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
        [String] $FQDD
    )

    Process 
    {
        Write-Verbose "Getting Network device statistics for $($iDRACSession.ComputerName) ..."
        
        if ($FQDD)
        {
            $filter = "FQDD='$FQDD'"
        }
        else
        {
            $filter = $null
        }
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_NICStatistics -Namespace root\dcim -Filter $filter
    
    }
}

Export-ModuleMember -Function *
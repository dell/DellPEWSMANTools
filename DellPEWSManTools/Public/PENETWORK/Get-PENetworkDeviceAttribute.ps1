<#
Get-PENetworkDeviceAttribute.ps1 - Gets PE network device attributes.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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

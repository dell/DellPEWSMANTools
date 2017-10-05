<#
Get-PEBIOSAttribute.ps1 - Gets a list of BIOS attributes

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>

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

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_BIOSEnumeration -Namespace root\dcim -Filter $filter -ErrorAction Stop
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

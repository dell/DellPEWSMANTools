<#
Get-PELCAttribute.ps1 - GET PE Life cycle controller attributes.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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
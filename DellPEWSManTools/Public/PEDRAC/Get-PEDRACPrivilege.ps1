<#
Get-PEDRACPrivilege.ps1 - Gets PE DRAC privileges.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Get-PEDRACPrivilege 
{
    [CmdletBinding()]
    [OutputType([int])]
    # Suppressing this for now, since there are 2 types of output
    # This needs to be refactored -> https://github.com/rchaganti/DellPEWSMANTools/issues/21
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly',
        '', Scope='Function')]
    param (
        [Parameter(ParameterSetName='EncodeSpecial')]
        [ValidateSet('Admin','ReadOnly','Operator')]
        [String]$SpecialPrivilege,

        [Parameter(ParameterSetName='EncodeGroup')]
        [ValidateSet('Login','Configure','ConfigureUser','Logs','SystemControl','AccessVirtualConsole','AccessVirtualMedia','SystemOperation','Debug')]
        [String[]]$GroupedPrivilege,

        [Parameter(ParameterSetName='EncodeSpecial')]
        [Parameter(ParameterSetName='EncodeGroup')]
        [Switch]$Encode,

        [Parameter(ParameterSetName='Decode')]
        [Switch]$Decode,

        [Parameter(Mandatory,ParameterSetName='Decode')]
        [Int]$PrivilegeValue
    )

    Process 
    {
        if ($PSCmdlet.ParameterSetName -eq 'EncodeSpecial') 
        {
            [iDRAC.Privileges]$SpecialPrivilege -as [int]
        } 
        elseif ($PSCmdlet.ParameterSetName -eq 'EncodeGroup') 
        {
            $result = 0
            foreach ($privilege in $GroupedPrivilege) 
            {
                $result = $result -bor [iDRAC.Privileges]$privilege
            }
            $result
        } 
        else 
        {
            [iDRAC.Privileges]$PrivilegeValue
        }
    }
}
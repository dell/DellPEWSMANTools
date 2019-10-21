<#
Set-PESupportAssistAcceptEULA.ps1 - Accept EULA terms and conditions required for support assist registration and running supportassistcollection.

_author_ = Kristian Lamb <Kristian.Lamb@Dell.com> _version_ = 1.0

Copyright (c) 2019, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PESupportAssistAcceptEULA
{
    [CmdletBinding(DefaultParameterSetName='General')]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Begin
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        $cmdresponse = Invoke-CimMethod -InputObject $instance -MethodName SupportAssistAcceptEULA -CimSession $iDRACSession
        return $cmdresponse
    }
}

<#
Get-PESystemRepositoryBasedUpdateList.ps1 - GET PE system repository based update list.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Get-PESystemRepositoryBasedUpdateList
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_SoftwareInstallationService";Name="DCIM:SoftwareUpdate";}
    $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
    $returnXml = [xml] (Invoke-CimMethod -InputObject $instance -MethodName GetRepoBasedUpdateList -CimSession $iDRACSession).PackageList

    $componentReport = @()
    foreach ($instance in $returnXml.Cim.MESSAGE.SIMPLEREQ.'VALUE.NAMEDINSTANCE'.INSTANCENAME)
    {
        $propertyHash = [Ordered] @{}
        $propertyHash.Add('ComponentName',$instance.PROPERTY.Where({$_.Name -eq 'DisplayName'}).Value)
        $propertyHash.Add('UpdateVersion',$instance.PROPERTY.Where({$_.Name -eq 'PackageVersion'}).Value)
        $propertyHash.Add('InstalledVersion',$instance.'Property.array'.Where({$_.Name -eq 'ComponentInstalledVersion'}).'Value.Array'.Value)
        $componentReport += $propertyHash
    }
    $componentReport
}
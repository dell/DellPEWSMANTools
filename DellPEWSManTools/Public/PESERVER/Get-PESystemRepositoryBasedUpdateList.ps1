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
#Load management Data
$inventoryBlueprint = "${PSScriptRoot}\InventoryBlueprint.json"
$managementData = Get-Content -Path $inventoryBlueprint -Raw | ConvertFrom-Json
$pcieSlotType = @("00A5","00A6","00A7","00A8","00A9","00AA","00AB","00AC","00AD","00AE","00AF","00B0","00B1","00B2","00B3","00B4","00B5","00B6")

function New-DynamicParameter
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String] $Name,

        [Parameter()]
        $actionObject,

        [Parameter()]
        [Switch] $IsMandatory
    )

        $ParameterName = $Name
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $IsMandatory
        $ParameterAttribute.Position = 0

        $AttributeCollection.Add($ParameterAttribute)
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($actionObject)

        $AttributeCollection.Add($ValidateSetAttribute)

        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
}
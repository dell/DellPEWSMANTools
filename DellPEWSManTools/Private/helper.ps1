<#
.SYNOPSIS
Helper function to check if the attribute values passed as input are valid possible values.

.DESCRIPTION
Below is an example explaining why there is a need of this helper function
    Example - DCIM_LCService.SetAttribute() method accepts a collection of attribute values. See below:
    Qualifiers  Name                Type        Description/Values 
    IN, REQ     AttributeName       string      DCIM_LCAttribute.AttributeName  
    IN, REQ     AttributeValue[]    string      Pending or Current value to be set.

    Now in the Functions Set-PELCAttribute, we need to check if the possible values returned for that
    attribute contain all the input attribute values

.NOTES
This is an internal helper function to be used by SetAttribute() like methods to sanitize the input
attribute values passed.
#>
function TestPossibleValuesContainAttributeValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String[]]$PossibleValues,

        [Parameter(Mandatory)]
        [String[]]$AttributeValues
    )

    foreach ($AttributeValue in $AttributeValues) {
        # iterate over each attribute value and determine if the possible values contains it
        if ( -not ($PossibleValues -contains $AttributeValue)) {
            return $False
        }
    }
    return $True
}
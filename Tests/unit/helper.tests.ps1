# load the SUT
# ModulePath harcoded at the moment, can use buildhelpers later
$ModuleName = 'DellPEWSMANTools'
$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\$($Modulename).psd1"
Import-Module $ModulePath  -Force

Describe "TestPossibleValuesContainAttributeValues" {
    $TestCases = @(
        @{PossibleValues='Enabled';AttributeValues='Enabled';ExpectedResult=$true}
        @{PossibleValues='Enabled';AttributeValues='Disabled';ExpectedResult=$false}
        @{PossibleValues=@('Enabled','Disabled');AttributeValues='Enabled';ExpectedResult=$true}
        @{PossibleValues=@('Enabled','Disabled');AttributeValues='NA';ExpectedResult=$false}
        @{PossibleValues='Enabled';AttributeValues=@('Enabled','Disabled');ExpectedResult=$false}
        @{PossibleValues=@('Enabled','Disabled');AttributeValues=@('Enabled','Disabled');ExpectedResult=$true}
        @{PossibleValues=@('Enabled','Disabled');AttributeValues=@('Enabled','Disabled','NA');ExpectedResult=$false}
    )
    Context "Testing various permutation combination" {

        It "Checks if possible values <PossibleValues> contain attribute values <AttributeValues>" -TestCases $TestCases -Test {
            param($PossibleValues, $AttributeValues, $ExpectedResult)

            TestPossibleValuesContainAttributeValues -PossibleValues $PossibleValues -AttributeValues $AttributeValues |
                Should Be $ExpectedResult
        }
    }
}

<#
helper.tests.ps1 - Helper test scripts

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>

if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..\..
}


$PSVersion = $PSVersionTable.PSVersion.Major
Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

InModuleScope -ModuleName $ENV:BHProjectName {

    Describe "TestPossibleValuesContainAttributeValues" -Tag UnitTest {
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
}
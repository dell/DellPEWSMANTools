<#
Get-PEDRACInformation.tests.ps1 - Get PE DRAC Information Tests

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>

if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..\..\..
}

Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) 

InModuleScope -ModuleName $ENV:BHProjectName {
    Describe 'Get-PEDRACInformation' {
        
        Context "Querying the class is successful" {
            # Arrange
            Mock -Command Get-CimInstance -MockWith {
                [pscustomobject]@{
                    'iDRAC'=$true
                }
            } -ParameterFilter {
                # param filters here
                ($cimsession -ne $null) -and
                ($ClassName-eq 'DCIM_iDRACCardView') -and
                ($NameSpace -eq 'root\dcim')
            } -Verifiable

            # Act
            $Output = Get-PEDRACInformation -iDRACSession 'dummy'

            # Assert
            It "Should query the correct classname in correct namespace" {
                Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope Context
                Assert-VerifiableMocks # assert that our mock was called
            }

            It "Should return the mocked output" {
                $Output | Should NOT BeNullOrEmpty
                $Output.iDRAC | Should Be $True
            }


        }

        Context "Querying the class failed" {
            Mock -CommandName Get-CimInstance -MockWith { throw 'failure'} -ParameterFilter {
                ($cimsession -ne $null) -and
                ($ClassName -eq 'DCIM_iDRACCardView') -and
                ($NameSpace -eq 'root\dcim')
            } -Verifiable

            $Output = Get-PEDRACInformation -iDRACSession 'dummy' -ErrorVariable PEDRACInfoError -ErrorAction SilentlyContinue

            It "Should write the error to the error stream" {
                {Get-PEDRACInformation -iDRACSession 'dummy' -ErrorAction Stop} | Should Throw 'failure'
                $PEDRACInfoError | Should NOT BeNullOrEmpty
                $Output | Should BeNullOrEmpty
            }

            It "Should query the correct class and namespace" {
                Assert-VerifiableMocks
            }
        }

    }
}

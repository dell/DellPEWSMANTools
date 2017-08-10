if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..\..\..
}

Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) 

InModuleScope -ModuleName $ENV:BHProjectName {

    Describe "Get-PEADGroupInfo" {

        Context "Querying the class is successful" {
            Mock -Command Get-CimInstance -MockWith {
                [pscustomobject]@{
                    'InstanceID' = 'iDRAC.Embedded.1#ADGroup.1#Name'
                    'CurrentValue' = 'test'
                }
            } -ParameterFilter {
                # param filters her
                ($Filter -eq 'InstanceID like "%ADGroup.%"') -and 
                ($Property -Contains 'InstanceID') -and 
                ($Property -Contains 'CurrentValue') -and
                ($cimsession -ne $null) -and
                ($ClassName -eq 'DCIM_iDRACCardAttribute') -and
                ($NameSpace -eq 'root/dcim')
                
            } -Verifiable

            # Act
            $Output = Get-PEADGroupInfo -iDRACSession 'dummy' -ErrorAction SilentlyContinue

            # Assert
            It "Should query the correct class and namespace without any filter" {
                Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope Context
                Assert-VerifiableMocks
            }

            It "Should return the hashtable with details from mocked object" {
                $Output | Should NOT BeNullOrEmpty
                $Output["ADGroup1"].Name | Should Be 'test'
            }
        }

        
        Context "Querying the class failed" {
            
            Mock -Command Get-CimInstance -MockWith {
                Write-Error "failure"
            } -ParameterFilter {
                # param filters her
                ($Filter -eq 'InstanceID like "%ADGroup.%"') -and 
                ($Property -Contains 'InstanceID') -and 
                ($Property -Contains 'CurrentValue') -and
                ($cimsession -ne $null) -and
                ($ClassName -eq 'DCIM_iDRACCardAttribute') -and
                ($NameSpace -eq 'root/dcim')
                
            } -Verifiable

            It "Should throw a fixed terminating error" {
                {Get-PEADGroupInfo -iDRACSession 'dummy' -ErrorAction Stop} | Should Throw 'Could Not Retrieve AD Group Information for '
            }

            It "Should query the correct class and namespace" {
                Assert-VerifiableMocks
            }
        }
        
    }
}
if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..\..
}


Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force
$PEDRACSessionParamHash = @{
    IPAddress = '192.168.1.1'
    Credential = $(New-Object -TypeName PSCredential -ArgumentList 'root', $(ConvertTo-SecureString -String 'calvin' -AsPlainText -Force))
}
Describe 'New-PEDRACSession' -Tag UnitTest {

    Context "Opening a CIM Session to PE Server failed" {
        
        # Arrange
        Mock -CommandName New-CimSessionOption -MockWith {} -Verifiable
        Mock -CommandName New-CimSession -MockWith {throw "failure"} -Verifiable
        Mock -CommandName Get-PESystemInformation

        # Act
        $PEDRACSession = New-PEDRACSession @PEDRACSessionParamHash -ErrorAction SilentlyContinue
        
        # Assert
        It "Should create custom CIMSession options"{
            Assert-MockCalled -CommandName New-CimSessionOption -Times 1 -Exactly -Scope Context
        }

        It "Should try creating the CIMSession" {
            Assert-MockCalled -CommandName New-CimSession -Times 1 -Exactly -Scope Context
            $PEDRACSession | Should BeNullOrEmpty
        }

        It "Should not continue execution" {
            Assert-MockCalled -CommandName Get-PESystemInformation -Times 0 -Exactly -Scope Context
        }

        It "Should throw the error back" {
            {New-PEDRACSession @PEDRACSessionParamHash -ErrorAction Stop} | Should Throw "failure"
        }

    }

    Context "Opening a CIM Session to PE Server is successful" {
        # Arrange
        Mock -CommandName New-CimSessionOption
        Mock -CommandName New-CimSession -MockWith {
            [pscustomobject]@{
                Id = 1;
                Name = 'CimSession1';
                ComputerName = '192.168.1.1'
                InstanceID = $([System.Guid]::NewGuid())
                Protocol = 'WSMAN'
            }
        }
        Mock -CommandName Get-PESystemInformation -MockWith {
            [pscustomobject]@{
                SystemGeneration='13G Monolithic'
            }
        }

        # Act
        $PEDRACSession = New-PEDRACSession @PEDRACSessionParamHash

        # Assert
        It "Should create custom CIMSession options"{
            Assert-MockCalled -CommandName New-CimSessionOption -Times 1 -Exactly -Scope Context
        }

        It "Should try creating the CIMSession" {
            Assert-MockCalled -CommandName New-CimSession -Times 1 -Exactly -Scope Context
            $PEDRACSession | Should NOT BeNullOrEmpty
        }

        It "Should continue execution and query PESystemInfo to determine generation and type" {
            Assert-MockCalled -CommandName Get-PESystemInformation -Times 1 -Exactly -Scope Context
        }

        It "Should add System generation to returned object" {
            $PEDRACSession.SystemGeneration | Should Be '13'
        }

        It "Should add System type to returned object" {
            $PEDRACSession.SystemType | Should Be 'Monolithic'
        }
    }
}
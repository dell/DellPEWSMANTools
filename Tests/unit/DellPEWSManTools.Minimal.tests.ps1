<#
DellPEWSManTools.Minimal.tests.ps1 - Dell PE WSman Tools minimal tests

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

$PrivateFunctions = Get-ChildItem "$ENV:BHModulePath\Private\" -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch "Tests.ps1"}
$PublicFunctions = Get-ChildItem "$ENV:BHModulePath\Public\" -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch "Tests.ps1"}

#$PrivateFunctionsTests = Get-ChildItem "$ENV:BHProjectPath\Tests\" -Filter '*Tests.ps1' -Recurse 
#$PublicFunctionsTests = Get-ChildItem "$ENV:BHProjectPath\Public\" -Filter '*Tests.ps1' -Recurse 

$Rules = Get-ScriptAnalyzerRule 

$manifest = Get-Item $ENV:BHPSModuleManifest

$module = $manifest.BaseName

Import-Module "$ENV:BHPSModuleManifest" -Force 

$ModuleData = Get-Module $Module 
$AllFunctions = & $moduleData {Param($modulename) Get-command -CommandType Function -Module $modulename} $module

if ($PrivateFunctions.count -gt 0) 
{
    foreach($PrivateFunction in $PrivateFunctions)
    {

        Describe "Testing Private Function  - $($PrivateFunction.BaseName) for Standard Processing" {
        
            It "Is valid Powershell (Has no script errors)" {

                    $contents = Get-Content -Path $PrivateFunction.FullName -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                    $errors.Count | Should Be 0
                }

        } 
    }
}

 
if ($PublicFunctions.count -gt 0) {

    foreach($PublicFunction in $PublicFunctions)
    {

        Describe "Testing Public Function  - $($PublicFunction.BaseName) for Standard Processing" {
        
            It "Is valid Powershell (Has no script errors)" {

                    $contents = Get-Content -Path $PublicFunction.FullName -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                    $errors.Count | Should Be 0
                }

            foreach ($rule in $rules) 
            {
                It "passes the PSScriptAnalyzer Rule $rule" {
                    (Invoke-ScriptAnalyzer -Path $PublicFunction.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0

                }
            }
        }
    }
}


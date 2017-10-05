<#
New-PEDRACSession.ps1 - Creates a new PE DRAC session.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function New-PEDRACSession
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='low')]
    [OutputType([Microsoft.Management.Infrastructure.CimSession])]
    param (
        [Parameter (Mandatory)]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter (Mandatory,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    ValueFromRemainingArguments=$false)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [string] $IPAddress,

        [Parameter()]
        [int] $MaxTimeout = 60
    )

    Begin
    {
        $cimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Creating iDRAC session..."

        if ($PSCmdlet.ShouldProcess($IPAddress,'Create iDRAC session'))
        {
            try
            {
                $session = New-CimSession -Authentication Basic -Credential $Credential -ComputerName $IPAddress -Port 443 -SessionOption $cimOptions -OperationTimeoutSec $MaxTimeout -ErrorAction Stop
                if ($session)
                {
                    $sysInfo = Get-PESystemInformation -iDRACSession $Session
                    Add-Member -inputObject $Session -Name SystemGeneration -Value $([int](([regex]::Match($sysInfo.SystemGeneration,'\d+')).groups[0].Value)) -MemberType NoteProperty
                    Add-Member -inputObject $Session -Name SystemType -Value $([regex]::Match($sysInfo.SystemGeneration,'(?<=\s).*').groups[0].Value) -MemberType NoteProperty
                    return $session     
                }
            }
            catch
            {
                Write-Error -Message $_
            }
        }
        
    }

    End
    {

    }
}
<#
Get-PEConfigurationShare.ps1 - GET PE configuration sahre.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Get-PEConfigurationShare 
{
    [CmdletBinding()]
    [OutputType([System.Collections.HashTable])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String]$ShareName,

        [Parameter()]
        [ValidateSet('NFS','CIFS')]
        [String]$ShareType = "CIFS",

        [Parameter()]
        [PSCredential]$Credential,

        [Parameter()]
        [Switch]$Validate
    )
    
    Begin 
    {
        $Parameters = @{
            IPAddress = $IPAddress
            ShareName = $ShareName
            ShareType = [ShareType]$ShareType -as [int]
        }

        if ($Credential) 
        {
            $Parameters.Add('Username',$Credential.GetNetworkCredential().UserName)
            $Parameters.Add('Password',$Credential.GetNetworkCredential().Password)
            if ($Credential.GetNetworkCredential().Domain) 
            {
                $Parameters.Add('Workgroup',$Credential.GetNetworkCredential().Domain)
            }
        }

        if ($Validate) 
        {
            $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        }
    }

    Process 
    {
        If ($Validate) 
        {
            Write-Verbose 'Testing if the share is accessible from iDRAC'
            $Job = Invoke-CimMethod -InputObject $instance -MethodName TestNetworkShare -CimSession $iDRACSession -Arguments $Parameters
            if (-not ($job.ReturnValue -eq 0)) 
            {
                Write-Error $Job.Message
            } 
            else 
            {
                Write-Verbose 'Share access validation is completed successfully'
                $Parameters
            }
        } 
        else
        {
            Write-Verbose 'No share access validation requested. Returning the hashtable.'
            $Parameters
        }
    }
}
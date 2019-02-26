<#
Set-PESystemOneTimeBootSetting.ps1 - Sets PE System one time boot setting.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PESystemOneTimeBootSetting
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $OneTimeBootDevice
    )

    Begin
    {
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_BIOSService";Name="DCIM:BIOSService";}
        $instance = New-CimInstance -ClassName DCIM_BIOSService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        $possibleDevices = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName 'OneTimeUefiBootSeqDev' -Verbose
        if ($possibleDevices.PossibleValues -contains $OneTimeBootDevice)
        {
            if ($PSCmdlet.ShouldProcess($OneTimeBootDevice, "Set one time boot device setting"))
            {
                $params = @{
                    'Target'='BIOS.Setup.1-1'
                    'AttributeName'=@('OneTimeBootMode','OneTimeUefiBootSeqDev')
                    'AttributeValue'=@('OneTimeUefiBootSeq',$OneTimeBootDevice)
                }
                
                $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttributes -CimSession $iDRACsession -Arguments $params
                if ($responseData.ReturnValue -eq 0)
                {
                    Write-Verbose -Message 'One time boot mode configured successfully'
                    if ($responseData.RebootRequired -eq 'Yes')
                    {
                        Write-Verbose -Message 'One time boot mode change requires reboot.'
                    }
                }
                else
                {
                    Write-Warning -Message "One time boot mode change failed: $($responseData.Message)"
                }
            }
            
        }
        else
        {
            Write-Warning -Message "$OneTimeBootDevice is not a valid one time boot device."
        }
    }
}
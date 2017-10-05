<#
Reset-PEDRAC.ps1 - Resets PE DRAC.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
Function Reset-PEDRAC 
{
    [CmdletBinding(SupportsShouldProcess=$true,
                ConfirmImpact='High',
                DefaultParameterSetName='General')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ParameterSetName='DRAC')]
        [Parameter(Mandatory, 
                   ParameterSetName='SSL')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='DRAC')]
        [Parameter(ParameterSetName='SSL')]
        [Switch] $Force,

        [Parameter(ParameterSetName='DRAC')]
        [Switch] $DRACConfig,

        [Parameter(ParameterSetName='SSL')]
        [Switch] $SSLConfig,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='DRAC')]
        [ValidateSet('Graceful','Forced')]
        [String] $ResetType = 'Graceful'
    )
    
    Begin 
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }

        $Arguments = @{
            'Force' = [ResetType]$ResetType -as [int]
        }

        if ($pscmdlet.ParameterSetName -eq 'DRAC') 
        {
            $ResetMethod = 'iDRACResetCfg'    
        } 
        elseif ($pscmdlet.ParameterSetName -eq 'SSL') 
        {
            $ResetMethod = 'SSLResetCfg'
        } 
        else 
        {
            $ResetMethod = 'iDRACReset'
        }
    }

    Process
    {
        if ($pscmdlet.ShouldProcess($iDRACsession.ComputerName, $ResetMethod)) 
        {
            Write-Verbose "Performing ${ResetMethod} on the target system $($iDRACsession)"
            if ($pscmdlet.ParameterSetName -eq 'DRAC' -or $pscmdlet.ParameterSetName -eq 'General') 
            {
                $return = Invoke-CimMethod -InputObject $instance -CimSession $iDRACsession -MethodName $ResetMethod -Arguments $Arguments
            }
            else 
            {
                $return = Invoke-CimMethod -InputObject $instance -CimSession $iDRACsession -MethodName $ResetMethod
            }
            if ($return -ne 0) 
            {
                Write-Error $return.Message
            } 
            else 
            {
                Write-Verbose 'Reset initiated ...'
            }
        }
        
    }    
}
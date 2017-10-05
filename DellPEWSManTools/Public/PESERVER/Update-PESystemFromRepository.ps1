<#
Update-PESystemFromRepository.ps1 - Update PE system from DRM repository.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Update-PESystemFromRepository
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [String]$ShareName,

        [Parameter()]
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",

        [Parameter(Mandatory)]
        [PSCredential]$Credential,

        [Parameter(Mandatory)]
        [String]$CatalogFile,

        [Parameter()]
        [bool] $RebootNeeded = $False,

        [Parameter()]
        [Switch] $ValidateOnly 
    
    )

    Process 
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Update system from repository'))
        {
            $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_SoftwareInstallationService";Name="DCIM:SoftwareUpdate";}
            $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
                
            $Parameters = @{
                IPAddress = $IPAddress
                ShareName = $ShareName
                ShareType = ([ShareType]$ShareType -as [int])
                #Mountpoint = $ShareName
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
                CatalogFile = $CatalogFile
                RebootNeeded = $RebootNeeded
            }

            if ($ValidateOnly)
            {
                $Parameters.Add('ApplyUpdate',1)
            }
            else
            {
                $Parameters.Add('ApplyUpdate',0)
            }

            $job = Invoke-CimMethod -InputObject $instance -MethodName InstallFromRepository -CimSession $iDRACSession -Arguments $Parameters

            if ($ValidateOnly)
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Importing System Configuration for $($iDRACSession.ComputerName)"
                Get-PESystemRepositoryBasedUpdateList -iDRACSession $iDRACSession -Verbose
            }
        }
    }
}
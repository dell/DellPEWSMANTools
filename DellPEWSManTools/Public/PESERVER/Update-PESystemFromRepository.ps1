<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER IPAddress
Parameter description

.PARAMETER ShareName
Parameter description

.PARAMETER ShareType
Parameter description

.PARAMETER Credential
Parameter description

.PARAMETER CatalogFile
Parameter description

.PARAMETER RebootNeeded
Parameter description

.PARAMETER ValidateOnly
Parameter description

.EXAMPLE
An example

.NOTES
General notes
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
<#
.Synopsis
   Configures the Automatic backup schedule. 
.DESCRIPTION
   The Set-PEAutobackupSchedule cmdlet configures the backup schedule of a server. This cmdlet requires the iDRAC Session parameter.

    This cmdlet requires the following parameters as well
    IPAddress               IP address of NFS/CIFS share. This parameter is required if ShareType = 0 or 2
    ShareName               Share name of the NFS/CIFS network share
    Passphrase              Passphrase for the backup server profile
    ShareType               Type of network share (NFS=0, CIFS=2, vFlash = 4). Defaults to NFS=0
    Credential              PSCredential Object containing username and password
    ImageName               Name of the backup server profile image
    Domain                  Domain name for the network share
    Time                    Hh:mm (hour and minute of day to run)
    DayOfMonth              *, 1-28, L Default *
    WeekOfMonth             *, 1-4, L Only one of the characters above. Default *
    DayOfWeek               *, Mon, Tue, Wed, Thu, Fri, Sat, Sun Comma delimited
    Repeat                  1-366
    MaxNumberOfBackupArchives 1-50


.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER IPAddress               
IP address of NFS/CIFS share. This parameter is required if ShareType = 0 or 2

.PARAMETER ShareName               
Share name of the NFS/CIFS network share

.PARAMETER Passphrase              
Passphrase for the backup server profile

.PARAMETER ShareType               
Type of network share (NFS=0, CIFS=2, vFlash = 4). Defaults to NFS=0

.PARAMETER Credential
A PSCredential Object conatining username and password.

.PARAMETER ImageName               
Name of the backup server profile image

.PARAMETER Domain                  
Domain name for the network share

.PARAMETER Time                    
Hh:mm (hour and minute of day to run)

.PARAMETER DayOfMonth              
*, 1-28, L Default *

.PARAMETER WeekOfMonth             
*, 1-4, L Only one of the characters above. Default *

.PARAMETER DayOfWeek               
*, Mon, Tue, Wed, Thu, Fri, Sat, Sun Comma delimited

.PARAMETER Repeat                  
1-366

.PARAMETER MaxNumberOfBackupArchives 
Maximum Number of Backup Archives, 1-50

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.INPUTS
   iDRACSession, params, usePSShare(optional)
#>
function Set-PEAutobackupSchedule
{
    [CmdletBinding(DefaultParameterSetName='General',
                  PositionalBinding=$false,
                  SupportsShouldProcess=$true,
                  ConfirmImpact='low')]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Share')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='ShareWait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='SharePassThru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [Hashtable]$ShareObject,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [ValidateNotNullOrEmpty()]
        [String] $ImageName,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [SecureString] $Passphrase,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [String] $ScheduledStartTime = "TIME_NOW",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateScript(
            {
                if (-not ((1..28 -contains $_) -or ($_ -eq 'L') -or ($_ -eq '*')))
                {
                    $false
                } else {
                    $true
                }
            }
        )]
        [String] $DayOfMonth = "*",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateScript(
            {
                if (-not ((1..4 -contains $_) -or ($_ -eq 'L') -or ($_ -eq '*')))
                {
                    $false
                } else {
                    $true
                }
            }
        )]
        [String] $WeekOfMonth = "*",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateSet('Mon','Tue','Wed','Thu','Fri','Sat','Sun','*')]
        [String[]] $DayOfWeek = "*",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateRange(1,366)]
        [Int] $Repeat,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateRange(1,50)]
        [Int] $MaxNumberOfBackupArchives,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ShareName,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet("NFS","CIFS","VFLASH")]
        [String]$ShareType = "NFS",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName='SharePassThru')]
        [Parameter(ParameterSetName='Passthru')]
        [Switch]$Passthru,

        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ShareWait')]
        [Switch]$Wait
    )

    Begin
    {
        $Parameters=@{}
        if ($ShareObject) 
        {
            $Parameters = $ShareObject.Clone()
        } 
        else 
        {
            $Parameters = @{
                IPAddress = $IPAddress
                ShareName = $ShareName
                ShareType = ([ShareType]$ShareType -as [int])
            }

            if ($Credential) 
            {
                $Parameters.Add('Username',$Credential.GetNetworkCredential().UserName)
                $Parameters.Add('Password',$Credential.GetNetworkCredential().Password)
                if ($Credential.GetNetworkCredential().Domain) 
                {
                    $Parameters.Add('Domain',$Credential.GetNetworkCredential().Domain)
                }
            }
        }

        if ($Passphrase)
        {
            # Passphrase is a secure string, hence this needs to be done to pass it in plain text
            $tempCred = New-Object -TypeName PSCredential -ArgumentList 'temp',$Passphrase
            $Parameters.Add('Passphrase', $($tempCred.GetNetworkCredential().Password))
        }
        $Parameters.Add('Time', $ScheduledStartTime)
        $Parameters.Add('DayOfMonth', $DayOfMonth)
        $Parameters.Add('WeekOfMonth', $WeekOfMonth)
        $Parameters.Add('DayOfWeek', $DayOfWeek)
        if ($Repeat) 
        {
            $Parameters.Add('Repeat', $Repeat)
        }

        if ($MaxNumberOfBackupArchives) 
        {
            $Parameters.Add('MaxNumberOfBackupArchives', $MaxNumberOfBackupArchives)
        }
        $Parameters.Add('ImageName', $ImageName)
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set autobackup schedule'))
        {
            Write-Verbose "Automatic Backup is being scheduled for $($iDRACSession.ComputerName) with ImageName $($Parameters.ImageName)"
            $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

            $argMap = @{AttributeName="Automatic Backup Feature";AttributeValue="Enabled"}
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttribute -CimSession $iDRACSession -Arguments $argMap
            if ($responseData.ReturnValue -ne 0)
            {
                throw "Attribute configuration failed with an error: $($responseData.Message)"
            }

            Write-Verbose "Creating Configuration Job on $($iDRACSession.ComputerName)"
            $argMap = @{ScheduledStartTime="TIME_NOW"}
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName CreateConfigJob -CimSession $iDRACSession -Arguments $argMap

            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuration Job for $($iDRACSession.ComputerName)"
                    Write-Verbose "Configuration Job on $($iDRACSession.ComputerName) was successful"
                }
            } else 
            {
                Throw "Configuration Job Creation failed with error: $($responseData.Message)"
            }

            $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

            $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetBackupSchedule -CimSession $iDRACSession -Arguments $Parameters 2>&1

            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Automatic Backup Schedule for $($iDRACSession.ComputerName)"
                    Write-Verbose "Automatic Backup Schedule on $($iDRACSession.ComputerName) was successful"
                }
            } 
            else 
            {
                Throw "Automatic Backup Schedule failed with error: $($responseData.Message)"
            }
        }
        
    }
}

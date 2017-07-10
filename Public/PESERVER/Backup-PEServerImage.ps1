
<#
.Synopsis
   Backup firmware and configurations for the Lifecycle Controller
.DESCRIPTION
   This cmdlet copies the firmware and configurations from a PowerEdge Server system to an image file and store it at a specified share.
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Backup-PEServerImage -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session and uses that to create a backup server image job
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a back server image job. The -Credential parameter is used to specify the share credentials
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
.EXAMPLE
   The following example uses -ImageName parameter to specify a name for the backup image.

   Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ImageName Server1-Image.img
.EXAMPLE
   The -ShareType can be used to specify a NFS share type. 
   Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS
.EXAMPLE
   The -PassPhrase parameter is used to secure the backup image
   Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Passphrase 'P@ssW0rd1'

   The -Passthru parameter can be used to retrieve the job object
   $BackupJob = Backup-PEServerImage -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Passphrase 'P@ssW0rd1' -Passthru
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   When building this hash ShareType must be an integer to represent NFS (0) or CIFS (2). Username and password must be provided as plain-text values.
   $Credential = 
   $Share = @{
    IPAddress = '10.10.10.100'
    ShareName = 'Config'
    Sharetype = 2
    Username = 'root'
    Password = 'calvin'
    workgroup = 'test'
   }
   Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Passthru parameter returns the created job object.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $BackupJob = Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession -Passthru
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Wait parameter provides the progress of the backup job until it completes.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $BackupJob = Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession -Wait
.EXAMPLE
    The -ScheduledStartTime parameter can be used to specify a different date and time for starting the backup job. This should be specified in the format yyyymmddhhmmss.
    $Date = Get-Date '11/12/2014 21:30'
    $StringDate = $Date.ToString("yyyymmddhhmmss")
    $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $BackupJob = Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StringDate
.EXAMPLE
    The -UntilTime parameter can be used to specify an end date and time for completing the backup job. This should be specified in the format yyyymmddhhmmss.
    $StartDate = Get-Date '11/12/2014 21:30'
    $StartString = $Date.ToString("yyyymmddhhmmss")

    $EndDate = Get-Date '11/12/2014 23:30'
    $EndString = $Date.ToString("yyyymmddhhmmss")

    $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $BackupJob = Backup-PEServerImage -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StartString -UntilTime $EndString
.INPUTS
   iDRACSession - CIM session with an iDRAC
   ShareObject - A hashtable of network share properties either contructed manually or by using Get-PEConfigurationShare cmdlet
   IPAddress - IPAddress of the network share
   ShareName - Name of the Network share
   ShareType - Type of network share (NFS/CIFS)
   Credential - Credentials to access the network share
   ImageName - Name of the backup image. By default, the computername from iDRACsession will be used for the image name
   PassPhrase - Passphrase to secure the backup image
   ScheduledStartTime - Specifies the scheduled start time for the backup job. The format for time is yyyymmddhhmmss. The default value is TIME_NOW which means the job will start immediately.
   UntilTime - Specifies the end time for backup job. The format for time is yyyymmddhhmmss.
   Passthru - Returns the backup job object
   Wait - Waits till the backup job is complete
#>
function Backup-PEServerImage 
{
    [CmdletBinding(DefaultParameterSetName='General')]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Alias("s")]
        [Parameter(Mandatory,
                   ParameterSetName='Passthru')]
        [Parameter(Mandatory, 
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   ParameterSetName='Share')]
        [Parameter(Mandatory, 
                   ParameterSetName='ShareWait')]
        [Parameter(Mandatory, 
                   ParameterSetName='SharePassThru')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [String]$ShareName,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [string]$ImageName,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [SecureString]$Passphrase,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [String]$ScheduledStartTime = 'TIME_NOW',

        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [Hashtable]$ShareObject,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [String]$UntilTime,

        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='SharePassThru')]
        [Switch]$Passthru,

        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ShareWait')]
        [Switch]$Wait
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        if ($Share) 
        {
            $Parameters = $ShareObject.Clone()
        } 
        else 
        {
            $Parameters = @{
                IPAddress = $IPAddress
                ShareName = $ShareName
                ShareType = ([ShareType]$ShareType -as [int])
                SheduledStartTime = $ScheduledStartTime
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
        }

        if ($Passphrase) 
        {
            # Passphrase is a secure string, hence this needs to be done to pass it in plain text
            $tempCred = New-Object -TypeName PSCredential -ArgumentList 'temp',$Passphrase
            $Parameters.Add('Passphrase', $($tempCred.GetNetworkCredential().Password))
        }

        if ($UntilTime) 
        {
            $Parameters.Add('Untiltime',$UntilTime)
        }

    }

    Process 
    {
        if (-not $ImageName) 
        {
            $ImageName = "$($iDRACSession.Computername)-Image.img"
        }
        Write-Verbose "Server image will be backed up as ${ImageName}"
        $Parameters.Add('ImageName',$ImageName)
        $job = Invoke-CimMethod -InputObject $instance -MethodName BackupImage -CimSession $iDRACSession -Arguments $Parameters
        if ($Job.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $job
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "backup System image for $($iDRACSession.ComputerName)"
            }
        }
        else
        {
            Throw "Job Creation failed with error: $($Job.Message)"
        }
        
    }
}

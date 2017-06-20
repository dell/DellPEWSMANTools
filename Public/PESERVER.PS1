<#
.Synopsis
   Gets PowerEdge Server system information using iDRAC WSMAN interfaces
.DESCRIPTION
   Gets PowerEdge Server system information using iDRAC WSMAN interfaces
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   
   Get-PESystemInformation
.EXAMPLE
   The following example creates an iDRAC session and 
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PESystemInformation -iDRACSession $iDRACSession
.INPUTS
   iDRACSession - CIM session with an iDRAC
.OUTPUTS
   Microsoft.Management.Infrastructure.CimInstance
#>
function Get-PESystemInformation
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process
    {

        Write-Verbose "Getting System Information for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_SystemView" -Namespace "root/dcim"
    
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PEMemory
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession
    )

    Process
    {
        Write-Verbose "Getting System Information for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_MemoryView" -Namespace "root/dcim"
    }
}
<#
.Synopsis
   Sets the Power State of a PowerEdge Server system
.DESCRIPTION
   This cmdlet can be used to set the Power State of a PowerEdge Server System.
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   
   Set-PEPowerState

   Without the -State parameter, this cmdlet will attempt to PowerOn the target system.
.EXAMPLE
   The following example creates an iDRAC session and specifies PowerOff state using -State parameter
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff
.EXAMPLE
   The following example creates an iDRAC session, specifies PowerCycle state using -State parameter, and uses -Force to avoid prompting
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff -Force
.EXAMPLE
   The following example creates an iDRAC session, specifies PowerCycle state using -State parameter, and uses -Force to avoid prompting.
   Using -Passthru returns the object from the method invocation. This include the ReturnValue property from the method execution.
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff -Force -Passthru
.INPUTS
   iDRACSession - CIM session with an iDRAC
   State - Intended state of the target system - PowerOn, PowerOff, PowerCycle
   Force - Eliminates prompting to confirm the action
   Passthru - returns the object from the method invocation
#>
function Set-PEPowerState
{
    [CmdletBinding(
                SupportsShouldProcess=$true,
                ConfirmImpact="High",
                DefaultParameterSetName='General'
    )]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ParameterSetName='Passthru')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet("PowerOn","PowerOff","PowerCycle")]
        [String] $State = 'PowerOn',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Force,
        
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin 
    {
        $properties=@{CreationClassName="DCIM_ComputerSystem";Name="srv:system";}
        $instance = New-CimInstance -ClassName DCIM_ComputerSystem -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }
    }

    Process 
    {
        if ($pscmdlet.ShouldProcess($iDRACSession.ComputerName, $State))
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName RequestStateChange -CimSession $iDRACSession -Arguments @{'RequestedState'= [PowerState]$State -as [int]}
            if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
            {
                $job
            }
        }
        
    }
}

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
        [String]$Passphrase,

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
            $Parameters.Add('Passphrase',$Passphrase)
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

<#
.Synopsis
   Exports Server Configuration profile as XML
.DESCRIPTION
   This cmdlet Exports the component configuration from the server system as XML file to a specified share
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Export-PEServerConfigurationProfile -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session and uses that to create a Export Server profile job
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a Export System Profile job. The -Credential parameter is used to specify the share credentials
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
.EXAMPLE
   The following example uses -FileName parameter to specify a name for the XML profile.

   Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -FileName Server1.xml
.EXAMPLE
   The -ShareType can be used to specify a NFS share type. 
   Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS
.EXAMPLE
   The -ExportUse parameter is used to specify the type of export. The valid values are Default, Clone, and Replace.
  Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ExportUse Clone
.EXAMPLE
   The -Passthru parameter can be used to retrieve the job object
   $ExportJob = Export-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Passthru
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
   Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Passthru parameter returns the created job object.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ExportJob = Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Passthru
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Wait parameter provides the progress of the export job until it completes.
   $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ExportJob = Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Wait
.EXAMPLE
    The -ScheduledStartTime parameter can be used to specify a different date and time for starting the export job. This should be specified in the format yyyymmddhhmmss.
    $Date = Get-Date '11/12/2014 21:30'
    $StringDate = $Date.ToString("yyyymmddhhmmss")
    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $ExportJob = Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StringDate
.EXAMPLE
    The -UntilTime parameter can be used to specify an end date and time for completing the Export job. This should be specified in the format yyyymmddhhmmss.
    $StartDate = Get-Date '11/12/2014 21:30'
    $StartString = $Date.ToString("yyyymmddhhmmss")

    $EndDate = Get-Date '11/12/2014 23:30'
    $EndString = $Date.ToString("yyyymmddhhmmss")

    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $ExportJob = Export-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StartString -UntilTime $EndString
.INPUTS
   iDRACSession - CIM session with an iDRAC
   ShareObject - A hashtable of network share properties either contructed manually or by using Get-PEConfigurationShare cmdlet
   IPAddress - IPAddress of the network share
   ShareName - Name of the Network share
   ShareType - Type of network share (NFS/CIFS)
   Credential - Credentials to access the network share
   Target - Components for which the configuration export needs to be performed. Use the FQDD values of components in a comma separated format.
   FileName - Name of the XML file. By default, the computername from iDRACsession will be used for the file name
   ExportUse - Type of export needed. 
   ScheduledStartTime - Specifies the scheduled start time for the backup job. The format for time is yyyymmddhhmmss. The default value is TIME_NOW which means the job will start immediately.
   UntilTime - Specifies the end time for export job. The format for time is yyyymmddhhmmss.
   Passthru - Returns the export job object
   Wait - Waits till the export job is complete
#>
function Export-PEServerConfigurationProfile
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
        [string]$FileName,

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
        [string]$Target='All',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [ValidateSet('Default','Clone','Replace')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [String]$ExportUse = 'Default',

        [Parameter(Mandatory,
                   ParameterSetName='SharePassThru')]
        [Parameter(Mandatory,
                   ParameterSetName='ShareWait')]
        [Parameter(Mandatory,
                   ParameterSetName='Share')]
        [Hashtable]$ShareObject,

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
                ExportUse = ([ExportUse]$ExportUse -as [int])
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

        if ($Target) 
        {
            $Parameters.Add('Target', $Target)
        }

    }

    Process 
    {
        if (-not $FileName) 
        {
            $FileName = "$($iDRACSession.Computername)-Config.xml"
        }
        
        Write-Verbose "Server profile will be backed up as ${FileName}"
        $Parameters.Add('Filename',$FileName)
        $job = Invoke-CimMethod -InputObject $instance -MethodName ExportSystemConfiguration -CimSession $iDRACSession -Arguments $Parameters
        if ($job.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $job
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Exporting System Configuration for $($iDRACSession.ComputerName)"
            }
        } 
        else 
        {
            Throw "Job Creation failed with error: $($Job.Message)"
        }
    }
}

<#
.Synopsis
   Imports Server Configuration profile as XML
.DESCRIPTION
   This cmdlet imports the component configuration for the server system from an XML file to a specified share
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Import-PEServerConfigurationProfile -IPAddress 10.10.10.100 -ShareName Config -Filename Config.xml
.EXAMPLE
   The following example creates an iDRAC session and uses that to create a Export Server profile job
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Import-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Filename Config.xml
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a Import System Profile job. The -Credential parameter is used to specify the share credentials
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Import-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Filename Config.xml
.EXAMPLE
   The -ShareType can be used to specify a NFS share type. 
   Import-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS -Filename Config.xml
.EXAMPLE
   The -Passthru parameter can be used to retrieve the job object
   $ImportJob = Import-PEServerConfigurationProfile -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Filename Config.xml -Passthru 
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
   Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Filename Config.xml
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Filename Config.xml
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Passthru parameter returns the created job object.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ImportJob = Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Filename Config.xml -Passthru
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Wait parameter provides the progress of the export job until it completes.
   $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ImporttJob = Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Filename Config.xml -Wait
.EXAMPLE
    The -ScheduledStartTime parameter can be used to specify a different date and time for starting the import job. This should be specified in the format yyyymmddhhmmss.
    $Date = Get-Date '11/12/2014 21:30'
    $StringDate = $Date.ToString("yyyymmddhhmmss")
    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $ImportJob = Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StringDate -Filename Config.xml
.EXAMPLE
    The -UntilTime parameter can be used to specify an end date and time for completing the import job. This should be specified in the format yyyymmddhhmmss.
    $StartDate = Get-Date '11/12/2014 21:30'
    $StartString = $Date.ToString("yyyymmddhhmmss")

    $EndDate = Get-Date '11/12/2014 23:30'
    $EndString = $Date.ToString("yyyymmddhhmmss")

    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $ImportJob = Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StartString -UntilTime $EndString -Filename Config.xml
.EXAMPLE
    The following example specifies that the configuration XML be previewed without actually applying it.
    Import-PEServerConfigurationProfile -ShareObject $Share -iDRACSession $iDRACSession -Preview -FileName Config.xml
.INPUTS
   iDRACSession - CIM session with an iDRAC
   ShareObject - A hashtable of network share properties either contructed manually or by using Get-PEConfigurationShare cmdlet
   IPAddress - IPAddress of the network share
   ShareName - Name of the Network share
   ShareType - Type of network share (NFS/CIFS)
   Credential - Credentials to access the network share
   Target - Components for which the configuration import needs to be performed. Use the FQDD values of components in a comma separated format.
   FileName - Name of the XML file. By default, the computername from iDRACsession will be used for the file name
   Preview - Specifies that only a verification needs to be performed instead of actual import job
   ShutdownType - Type of system shutdown to be performed
   EndHostPowerState - Specifies if the system should be power on or off at the end of job
   ScheduledStartTime - Specifies the scheduled start time for the backup job. The format for time is yyyymmddhhmmss. The default value is TIME_NOW which means the job will start immediately.
   UntilTime - Specifies the end time for import job. The format for time is yyyymmddhhmmss.
   Passthru - Returns the import job object
   Wait - Waits till the import job is complete
#>
function Import-PEServerConfigurationProfile 
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

        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Passthru')]
        [Parameter(Mandatory, ParameterSetName='Wait')]
        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [string]$FileName,

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
        [string]$Target,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('Graceful','Forced')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [String]$ShutdownType = 'Graceful',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateSet('Off','On')]
        [String]$EndHostPowerState = 'On',

        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='SharePassThru')]
        [Switch]$Passthru,

        [Parameter(Mandatory,
                   ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [Hashtable]$ShareObject,

        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ShareWait')]
        [Switch]$Wait,

        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [Switch]$Preview
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        if ($ShareObject) 
        {
            $Parameters = $ShareObject.Clone()
            $Parameters.Add('FileName', $FileName)
        } 
        else 
        {
            $Parameters = @{
                IPAddress = $IPAddress
                ShareName = $ShareName
                ShareType = ([ShareType]$ShareType -as [int])
                FileName = $FileName
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

        if ($Target) 
        {
            $Parameters.Add('Target', $Target)
        }

        if (-not $Preview) 
        {
            $Parameters.Add('ShutdownType',[ShutdownType]$ShutdownType -as [int])
            $Parameters.Add('EndHostPowerState',[EndHostPowerState]$EndHostPowerState -as [int])
        }

    }

    Process 
    {

        if ($Preview) 
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName ImportSystemConfigurationPreview -CimSession $iDRACSession -Arguments $Parameters
        } 
        else 
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName ImportSystemConfiguration -CimSession $iDRACSession -Arguments $Parameters
        }

        if ($job.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $job
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Importing System Configuration for $($iDRACSession.ComputerName)"
            }
        } 
        else 
        {
            Throw "Job Creation failed with error: $($Job.Message)"
        }
    }
}

<#
.Synopsis
   Exports Server health report for tech support
.DESCRIPTION
   This cmdlet exports server health report as a ZIP archive to the specified share
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Export-PETechSupportReport -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session and uses that to create a Export Tech Support Report
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Export-PETechSupportReport -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a Export Tech Support Report job. The -Credential parameter is used to specify the share credentials
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Export-PETechSupportReport -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
.EXAMPLE
   The -ShareType can be used to specify a NFS share type. 
   Export-PETechSupportReport -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS
.EXAMPLE
   The -Passthru parameter can be used to retrieve the job object
   $ExportJob = Export-PETechSupportReport -iDRACSession $iDRACSession -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -Passthru
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
   Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Passthru parameter returns the created job object.
   $Share = Get-PEConfigurationJob -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ExportJob = Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession -Passthru
.EXAMPLE
   The -ShareObject parameter can be used to send a hashtable of share properties instead of explicit IPAddress, ShareName, and other properties
   This hashtable can be created using Get-PEConfigurationShare cmdlet. The -Wait parameter provides the progress of the export job until it completes.
   $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
   $ExportJob = Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession -Wait
.EXAMPLE
    The -ScheduledStartTime parameter can be used to specify a different date and time for starting the export job. This should be specified in the format yyyymmddhhmmss.
    $Date = Get-Date '11/12/2014 21:30'
    $StringDate = $Date.ToString("yyyymmddhhmmss")
    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $ExportJob = Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StringDate
.EXAMPLE
    The -UntilTime parameter can be used to specify an end date and time for completing the export job. This should be specified in the format yyyymmddhhmmss.
    $StartDate = Get-Date '11/12/2014 21:30'
    $StartString = $Date.ToString("yyyymmddhhmmss")

    $EndDate = Get-Date '11/12/2014 23:30'
    $EndString = $Date.ToString("yyyymmddhhmmss")

    $Share = Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
    $exportjob = Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession -ScheduledStartTime $StartString -UntilTime $EndString
.EXAMPLE
    Following example specifies a subset of data selectors for health report export. This needs to be a comma-separated list. HWDATA must always be specified.
    Export-PETechSupportReport -ShareObject $Share -iDRACSession $iDRACSession -DataSelector 'HWDATA','TTYLOGS'
.INPUTS
   iDRACSession - CIM session with an iDRAC
   ShareObject - A hashtable of network share properties either contructed manually or by using Get-PEConfigurationShare cmdlet
   IPAddress - IPAddress of the network share
   ShareName - Name of the Network share
   ShareType - Type of network share (NFS/CIFS)
   Credential - Credentials to access the network share
   DataSelector - Specifies the data set that needs to be exported 
   ScheduledStartTime - Specifies the scheduled start time for the export job. The format for time is yyyymmddhhmmss. The default value is TIME_NOW which means the job will start immediately.
   UntilTime - Specifies the end time for export job. The format for time is yyyymmddhhmmss.
   Passthru - Returns the export job object
   Wait - Waits till the export job is complete
#>
function Export-PETechSupportReport 
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

        [Parameter(Mandatory,
                   ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [Hashtable]$ShareObject,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [ValidateSet('OSAPPDATAWithoutPII','OSAPPDATA','HWDATA','TTYLOGS')]
        [String[]]$DataSelector = 'HWDATA',

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
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",

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
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        if ($DataSelector -notcontains 'HWDATA') 
        {
            $DataSelector += 'HWDATA'
        }

        $DataSelectorArray = foreach ($selector in $DataSelector) { [TechSupportSelector]$selector -as [int] }
        
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
                    $Parameters.Add('Workgroup',$Credential.GetNetworkCredential().Domain)
                }
            }
        }

        $Parameters.Add('DataSelectorArrayIn', $DataSelectorArray)
    }

    Process 
    {
 
        $job = Invoke-CimMethod -InputObject $instance -MethodName ExportTechSupportReport -CimSession $iDRACSession -Arguments $Parameters

        if ($job.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $job
            } 
            elseif ($Wait) 
            {
                if ($job.ReturnValue -eq 4096) {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Importing System Configuration for $($iDRACSession.ComputerName)"
                }
            }
        } 
        else 
        {
            Throw "Job creation failed with an error: $($Job.Message)"
        }
    }
}

<#
.Synopsis
   Update Server health report for tech support report
.DESCRIPTION
   This cmdlet updates the server health report
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Update-PEOSAppHealthData
.EXAMPLE
   The following example creates an iDRAC session and uses that to update Tech Support Report
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Update-PEOSAppHealthData -iDRACSession $iDRACSession
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a update Tech Support Report job. The -UpdateType parameter is used to specify if a manual update should be performed.
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Update-PEOSAppHealthData -iDRACSession $iDRACSession -UpdateType Manual
.EXAMPLE
   The -Passthru parameter can be used to retrieve the job object
   $ExportJob = Update-PEOSAppHealthData -iDRACSession $iDRACSession -UpdateType Manual -Passthru
.INPUTS
    iDRACSession - CIM session with an iDRAC
    UpdateType - Manual or AgentLiteOSPlugin based update
    Passthru - Returns the export job object
    Wait - Waits till the export job is complete
#>
function Update-PEOSAppHealthData
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
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [ValidateSet('AgentLiteOSPlugin','Manual')]
        [String]$UpdateType = 'AgentLiteOSPlugin',
        
        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [switch]$Wait,

        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $Parameters = @{
            UpdateType = [OSAPPUpdateType]$UpdateType -as [int]
        }
    }
    Process
    {
        $job = Invoke-CimMethod -InputObject $instance -MethodName UpdateOSAppHealthData -CimSession $iDRACSession -Arguments $Parameters
        if ($job.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $job
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -JobID $job.Job.EndpointReference.InstanceID -iDRACSession $iDRACSession -Activity 'Updating OS APP Health Data'
            }
        } 
        else 
        {
            Throw "Job creation failed with an error: $($job.Message)"
        }
    }
}

<#
.Synopsis
   This cmdlets provides the progress of a job object and waits till it is complete
.DESCRIPTION
   This cmdlets provides the progress of a job object and waits till it is complete
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Wait-PEConfigurationJob -JobID 'JobID String'
.EXAMPLE
   The following example creates an iDRAC session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Wait-PEConfigurationJob -JobID 'JobID String' -iDRACSession $iDRACSession
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
#>
Function Wait-PEConfigurationJob
{
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
    
        [Parameter (Mandatory)]
        $JobID,

        [Parameter()]
        [String]$Activity = 'Performing iDRAC job'
    )
    
    $jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
        
    if ($jobstatus.PercentComplete -eq 'NA') 
    {
        $PercentComplete = 0
    } 
    else 
    {
        $PercentComplete = $JobStatus.PercentComplete
    }
    
    while (($jobstatus.JobStatus -like 'Running') -or ($jobstatus.JobStatus -like '*Progress*') -or 
        ($jobstatus.JobStatus -like '*ready*') -or ($jobstatus.JobStatus -like '*pending*') -or 
        ($jobstatus.JobStatus -like '*downloading*'))
    {
        $jobstatus = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT InstanceID,JobStatus,Message,PercentComplete FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
        if ($jobstatus.JobStatus -notlike '*Failed*') 
        {
            if ($jobstatus.PercentComplete -eq 'NA') 
            {
                $PercentComplete = 0
            } 
            else 
            {
                $PercentComplete = $JobStatus.PercentComplete
            }
        } 
        else 
        {
            Throw "Job creation failed with an error: $($jobstatus.Message). Use 'Get-PEConfigurationResult -JobID $($jobstatus.Job.EndpointReference.InstanceID)' to receive detailed configuration result"
        }
        
        Write-Progress -activity "Job Status: $($JobStatus.Message)" -status "$PercentComplete % Complete:" -percentcomplete $PercentComplete
        Start-Sleep 1
    }
}

<#
.Synopsis
   This cmdlets provides detailed results from of a job object
.DESCRIPTION
   This cmdlets provides detailed results from of a job object
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Get-PEConfigurationResult -JobID 'JobID String'
.EXAMPLE
   The following example creates an iDRAC session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationResult -JobID 'JobID String' -iDRACSession $iDRACSession
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
#>
Function Get-PEConfigurationResult
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
    
        [Parameter(Mandatory)]
        $JobID
    )

    Begin 
    {
        $properties=@{InstanceID="DCIM:LifeCycleLog";}
        $instance = New-CimInstance -ClassName DCIM_LCRecordLog -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $Parameters = @{
            JobID = $JobID
        }
    }

    Process 
    {
        $Result = Invoke-CimMethod -InputObject $instance -MethodName GetConfigResults -CimSession $iDRACSession -Arguments $Parameters
        if ($Result.ReturnValue -eq 0) 
        {
            $Xml = $Result.COnfigResults
            $XmlDoc = New-Object System.Xml.XmlDocument
            $ConfigResults = $XmlDoc.CreateElement('Configuration')
            $ConfigResults.InnerXml = $Xml
            Foreach ($ConfigResult in $ConfigResults.ConfigResults) 
            {
                $ResultHash = [Ordered]@{
                    JobName = $ConfigResult.JobName
                    JobID = $ConfigResult.JobID
                    JobDisplayName = $ConfigResult.JobDisplayName
                    FQDD = $ConfigResult.FQDD
                }
                $OperationArray = @()
                Foreach ($Operation in $ConfigResult.Operation) 
                {
                    $OperationHash = [Ordered]@{
                        Name = $Operation.Name -join ' - '
                        DisplayValue = $Operation.DisplayValue
                        Detail = $Operation.Detail.NewValue
                        MessageID = $Operation.MessageID
                        Message = $Operation.Message
                        Status = $Operation.Status
                        ErrorCode = $Operation.ErrorCode
                    }
                    $OperationArray += $OperationHash      
                }
                $ResultHash.Add('Operation',$OperationArray)
                New-Object -TypeName PSObject -Property $ResultHash
            }
        } 
        else 
        {
            Write-Error $Result.Message
        }
        
    }
}

<#
.Synopsis
   This cmdletis a helper function that can be used to generate a hash table of properties
.DESCRIPTION
   This cmdletis a helper function that can be used to generate a hash table of properties and optionally validate if the share is accessible from iDRAC
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   Using the default iDRAC session, you can validate and generate the share object
   Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS -Validate
.EXAMPLE
   The following example generates the share object without validation
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
.INPUTS
    iDRACSession - CIM session with an iDRAC
    IPAddress - IPAddress of the share
    ShareName - Name of the network share
    ShareType - type of share (NFS/CIFS)
    Credential - Credentials to access the network share
    Validate - Validate if the share is accessible from iDRAC or not
#>
Function Get-PEConfigurationShare 
{
    [CmdletBinding()]
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

<#
.Synopsis
   This cmdlets gets the configuration job status
.DESCRIPTION
   This cmdlets gets the configuration job status and optionally waits for the job to complete
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Get-PEConfigurationJobStatus -JobID 'JobID String'
.EXAMPLE
   The following example gets the job status from a specified iDRAC Session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationJobStatus -JobID 'JobID String' -iDRACSession $iDRACSession
.EXAMPLE
   The following example waits for the job to complete
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationJobStatus -JobID 'JobID String' -iDRACSession $iDRACSession -Wait
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
    Wait - Wait for the job to complete
#>
Function Get-PEConfigurationJobStatus 
{
    [CmdletBinding(DefaultParameterSetName='General')]
    param (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   ParameterSetName='Wait')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory,
                    ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [String]$JobID,

        [Parameter(ParameterSetName='Wait')]
        [Switch]$Wait
    )

    Process
    {
        try 
        {
            $job = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LifecycleJob" -Namespace "root/dcim" -Query "SELECT * FROM DCIM_LifecycleJob Where InstanceID='$JobID'"
            if ($job) 
            {
                if ($Wait) 
                {
                    Wait-PEConfigurationJob -JobID $JobID -iDRACSession $iDRACSession -Activity 'Waiting for Job ...'
                } 
                else 
                {
                    $job
                }
            }
        }
        catch 
        {
            Write-Error $_            
        }
    }
}

<#
.Synopsis
   Creates a specific reboot job to power cycle the host system.
.DESCRIPTION
   The New-PERebootJobForSWUpdate cmdlet creates a specific reboot job to power cycle the host system. This cmdlet requires the iDRACSession parameter obtained from New-PEDRACSession cmdlet. 
   The cmdlet will Throw an error if it fails.
.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER RebootType
This specifies the type of reboot required. Possible values Forced, Graceful, PowerCycle.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType Forced

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType Graceful

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType PowerCycle

.INPUTS
   iDRACSession, Reboot Job Type
#>
function New-PERebootJobForSWUpdate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet('PowerCycle','Graceful','Forced')]
        $RebootType = 'PowerCycle',

        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="IDRAC:ID";CreationClassName="DCIM_SoftwareInstallationService";Name="SoftwareUpdate";}
        $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        $params=@{}
        $params.Add('RebootJobType',([ConfigJobRebootType]$RebootType -as [int]))
    }
    Process
    {

        $responseData = Invoke-CimMethod -InputObject $instance -MethodName CreateRebootJob -CimSession $iDRACSession -Arguments $params 2>&1
        if ($responseData.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $responseData
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.RebootJobID.EndpointReference.InstanceID -Activity "Rebooting for Software Update for $($iDRACSession.ComputerName)"
                Write-Verbose "Reboot for Software Update done seccessfully"
            }
        } 
        else 
        {
            Throw "Job Creation failed with error: $($responseData.Message)"
        }
    }
}

<#
.Synopsis
   Retrieves requested LCLog entry/entries 
.DESCRIPTION
   The Get-PELCLog cmdlet enumerates LCLogs. Based on input parameters, it may retreive complete LC Log or filter it out. 
   It also can export the complete LC Logs or the active LC Logs. A user may opt to use the built-in share for the cmdlet.
   This cmdlet requires the iDRACSession input parameter obtained from New-PEDRACSession cmdlet.
   This cmdlet requires the following parameters in case -exportType is specified,

        IPAddress The IP address of the target export server.
        ShareName The directory path to the mount point.
        FileName  The target output file name.
        ShareType Type of share: NFS, CIFS
        Credential Username and Password
        Workgroup The applicable workgroup.

    Alternatively, a share object may be created using Get-PEConfigurationShare and passed into the cmdlet as a ShareObject. 
    In this case, for exporting, only filename parameter will be required other than this.

    The cmdlet will Throw an error if it fails.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER RecordID
Filter results based on RecordID.

.PARAMETER AgentID
Filter results based on AgentID.

.PARAMETER Category
Filter results based on Category.

.PARAMETER Severity
Filter results based on Severity.

.PARAMETER ExportType
Setting this value indicates the Logs are expected to be exported to a share location. Possible values ActiveLogs, All.

.PARAMETER ShareObject
A share object obtained through Get-PEConfigurationShare cmdlet.

.PARAMETER IPAddress
IP Address of the share location.

.PARAMETER FileName
Filename whre the log needs to be exported.

.PARAMETER ShareName
Name of Share.

.PARAMETER ShareType
Type of share, NFS/CIFS.

.PARAMETER Credential
A PSCredential Object conatining username and password.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session

Retrieves all log entries

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -AgentID WSMAN

Retrieves all log entries whose AgentID is WSMAN

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -Category Configuration

Retrieves all log entries whose Category is Configuration

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -RecordID 150

Retrieves the log entry having RecordID 150

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -Severity 3

Retrieves all log entries having PerceivedSeverity 3

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -Severity 3 -AgentID RACLOG

Retrieves all log entries having PerceivedSeverity 3 and having AgentID RACLOG

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -ExportType ActiveLogs -ShareObject $shareObj -FileName lclog

This will export the Active LC Logs to the mentioned Share into the file lclog. The share object may be craeted by using Get-PEConfigurationShare cmdlet.

.EXAMPLE
PS C:\Users> Get-PELCLog -iDRACSession $session -ExportType All -ShareObject $shareObj -FileName lclog

This will export the Complete LC Logs to the mentioned Share into the file lclog. The share object may be craeted by using Get-PEConfigurationShare cmdlet.

.INPUTS
   iDRACSession, filterOption(optional), exportOption(optional), completeExportOption(optional), filename, shareparams
.OUTPUTS
   It may return list of CimInstances or boolean(if export is used)
#>
function Get-PELCLog
{
    [CmdletBinding(DefaultParameterSetName='Filter',
                  PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Export')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Share')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='ShareWait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='SharePassThru')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Filter')]                    
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='ExportWait')]                    
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='ExportPassthru')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='NoPassthruWait')]                    
        [ValidateNotNullOrEmpty()]
        [Alias("s")]                
        $iDRACSession,

        [Parameter(ParameterSetName="Filter")]
        [Alias ("id")]
		[String]
        $RecordID,

        [Parameter(ParameterSetName="Filter")]
        [Alias ("agent")]
		[String]
        $AgentID,
    
        [Parameter(ParameterSetName="Filter")]
        [Alias ("cat")]
		[String]
        $Category,

        [Parameter(ParameterSetName="Filter")]
        [Alias ("sev")]
		[String]
        $Severity,

        [Parameter(ParameterSetName='Export')]
        [Parameter(ParameterSetName='ExportWait')]
        [Parameter(ParameterSetName='ExportPassthru')]
        [Parameter(ParameterSetName='Share')]
        [Parameter(ParameterSetName='ShareWait')]
        [Parameter(ParameterSetName='SharePassThru')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [Alias ("exp")]
        [ValidateSet("All","ActiveLogs")]
        [String]$ExportType = 'ActiveLogs',

        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [Hashtable]$ShareObject,

        [Parameter(Mandatory,ParameterSetName='Export')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [Parameter(Mandatory,ParameterSetName='ExportWait')]
        [Parameter(Mandatory,ParameterSetName='ExportPassthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory,ParameterSetName='Export')]
        [Parameter(Mandatory,ParameterSetName='ExportWait')]
        [Parameter(Mandatory,ParameterSetName='ExportPassthru')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [Parameter(Mandatory,ParameterSetName='Share')]
        [Parameter(Mandatory,ParameterSetName='ShareWait')]
        [Parameter(Mandatory,ParameterSetName='SharePassThru')]
        [ValidateNotNullOrEmpty()]
        [String] $FileName,

        [Parameter(Mandatory,ParameterSetName='Export')]
        [Parameter(Mandatory,ParameterSetName='ExportWait')]
        [Parameter(Mandatory,ParameterSetName='ExportPassthru')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [ValidateNotNullOrEmpty()]
        [String]$ShareName,

        [Parameter(ParameterSetName='Export')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ExportWait')]
        [Parameter(ParameterSetName='ExportPassthru')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",

        [Parameter(ParameterSetName='Export')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ExportWait')]
        [Parameter(ParameterSetName='ExportPassthru')]
        [Parameter(ParameterSetName='NoPassthruWait')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName='ExportPassthru')]
        [Parameter(ParameterSetName='SharePassThru')]
        [Parameter(ParameterSetName='Passthru')]
        [Switch]$Passthru,

        [Parameter(ParameterSetName='ExportWait')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='ShareWait')]
        [Switch]$Wait
    )

    Begin
    {
        if ( $PSCmdlet.ParameterSetName -eq 'Filter')
        {
            $filtered = $false
            $query="Select * from DCIM_LCLogEntry"

            if ($RecordID) 
            {
                if (-not $filtered) 
                {
                    $query += " WHERE RecordID='$RecordID'"
                    $filtered = $true
                } 
                else 
                {
                    $query += " AND RecordID='$RecordID'"
                }
            }

            if ($AgentID) 
            {
                if (-not $filtered) {
                    $query += " WHERE AgentID='$AgentID'"
                    $filtered = $true
                } else {
                    $query += " AND AgentID='$AgentID'"
                }
            }

            if ($Category) 
            {
                if (-not $filtered) 
                {
                    $query += " WHERE Category='$Category'"
                    $filtered = $true
                }
                else 
                {
                    $query += " AND Category='$Category'"
                }
            }

            if ($Severity) 
            {
                if (-not $filtered) 
                {
                    $query += " WHERE PerceivedSeverity='$Severity'"
                    $filtered = $true
                } 
                else 
                {
                    $query += " AND PerceivedSeverity='$Severity'"
                }
            }
        else 
        {
            $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
             
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
                        $Parameters.Add('Workgroup',$Credential.GetNetworkCredential().Domain)
                    }
                }
            }
            # Add the mandatory parameter filename
            $Parameters.Add('FileName', $FileName)
        }
    }
    }
    Process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Filter')
        {
            Write-Verbose "Retrieving only filtered logs with a query ${query}..."
            $responseData = Get-CimInstance -CimSession $iDRACSession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_LCLogEntry" -Namespace "root/dcim" -Query $query -QueryDialect "http://schemas.dmtf.org/wbem/cql/1/dsp0202.pdf"
            $responseData
        } 
        else 
        {
            Write-Verbose "Exporting Lifecycle Log from $($iDRACSession.ComputerName) to $($Parameters.FileName)"
            if ( $ExportType -eq 'ActiveLogs' ) 
            {
                $responseData = Invoke-CimMethod -InputObject $instance -MethodName ExportLCLog -CimSession $iDRACSession -Arguments $Parameters
            } 
            else 
            {
                $responseData = Invoke-CimMethod -InputObject $instance -MethodName ExportCompleteLCLog -CimSession $iDRACSession -Arguments $Parameters
            }

            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Exporting Lifecycle Log for $($iDRACSession.ComputerName)"
                    Write-Verbose "Exporting Lifecycle Log from $($iDRACSession.ComputerName) to $($Parameters.FileName) was successful"
                }
            } 
            else 
            {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }

        }
    }
}

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
                  PositionalBinding=$false)]
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
        [String] $Passphrase,

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

        $Parameters.Add('Passphrase', $Passphrase)
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

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER Installed
Parameter description

.PARAMETER Available
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function  Get-PESoftwareInventory
{
    [CmdletBinding(DefaultParameterSetName='General')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, ParameterSetName='General',)]
        [Parameter(Mandatory, ParameterSetName='Installed')]
        [Parameter(Mandatory, ParameterSetName='Available')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession,

        [Parameter(ParameterSetName='Installed')]
        [Switch] $Installed,

        [Parameter(ParameterSetName='Available')]
        [Switch] $Available
    )

    Process
    {
        if ($Available)
        {
            Write-Verbose "Getting available Software Inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Available'" -Namespace "root/dcim"
        }
        elseif ($Installed)
        {
            Write-Verbose "Getting installed software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Filter "Status='Installed'" -Namespace "root/dcim"
        }
        else
        {
            Write-Verbose "Getting software inventory for $($iDRACSession.ComputerName) ..."
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SoftwareIdentity -Namespace "root/dcim"
        }
    }
}

<#
.SYNOPSIS
This function gets a Lifecycle Controller attribute.

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER AttributeName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PELCAttribute
{
    [CmdletBinding(DefaultParameterSetName='All')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='All')]
        [Parameter(Mandatory,
                   ParameterSetName='Named')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory=$true,ParameterSetName='Named')]
        [String] $AttributeName
    ) 
       
    Begin
    {
        # Commenting this out, not being used
        # $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PE Lifecycle Controller attribute information ..."
        try
        {
            if ($psCmdlet.ParameterSetName -eq 'Named')
            {
                Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim -Filter "AttributeName='$AttributeName'"
            }
            else
            {
                Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim
            }
        }
        catch
        {
            Write-Error -Message $_
        }
    }

    End
    {

    }
}


<#
.SYNOPSIS
The function which sets an LC attribute.

.DESCRIPTION

The DCIM_LCService.SetAttribute() method is used to set or change the value of an LC attribute.
Invoking the SetAttribute() method shall change the value of the DCIM_LCAttribute.CurrentValue or
DCIM_LCAttribute.PendingValue property to the value specified by the AttributeValue parameter if the
DCIM_LCAttribute.IsReadOnly property is FALSE. Invoking this method when the 
DCIM_LCAttribute.IsReadOnly property is TRUE shall result in no change to the value of the
DCIM_LCAttribute.CurrentValue property. The results of changing this value is described with the 
SetResult parameter.

Return code values for the SetAttribute() method are specified in tables below.
    * 0 - Request was successfully executed
    * 2 - Error occurred

.PARAMETER iDRACSession
Pass the iDRACSession object created using New-PEDRACSession function.

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-PELCAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        # Sepcify the name of the attribute name to be set
        [Parameter()]
        [String] $AttributeName,

        # Pending or Current value to be set
        [Parameter()]
        [String[]] $AttributeValue        
    ) 

    Begin
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        #Chekck if the attribute is settable.
        $attribute = Get-PELCAttribute -iDRACSession $iDRACSession -AttributeName $AttributeName -Verbose
        
        if ($attribute)
        {
            if ($attribute.IsReadOnly -eq 'false')
            {
                Write-Verbose "setting PEBIOS attribute information ..."

                #Check if the AttributeValue falls in the same set as the PossibleValues, call the helper function
                if (TestPossibleValuesContainAttributeValues -PossibleValues $attribute.PossibleValues -AttributeValues $AttributeValue )
                {
                    try
                    {
                        $params = @{
                            'AttributeName'  = $AttributeName
                            'AttributeValue' = $AttributeValue
                        }

                        $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttribute -CimSession $iDRACSession -Arguments $params
                        if ($responseData.ReturnValue -eq 0)
                        {
                            Write-Verbose -Message 'LC attribute configured successfully'
                            if ($responseData.RebootRequired -eq 'Yes')
                            {
                                Write-Verbose -Message 'LC attribute change requires reboot.'
                            }
                        }
                        else
                        {
                            Write-Warning -Message "LC attribute change failed: $($responseData.Message)"
                        }
                    }
                    catch
                    {
                        Write-Error -Message $_
                    }
                }
                else
                {
                    Write-Error -Message "Attribute value `"${AttributeValue}`" is not valid for attribute ${AttributeName}."
                }
            }
            else
            {
                Write-Error -Message "${AttributeName} is readonly and cannot be configured."
            }
        }
        else
        {
            Write-Error -Message "${AttributeName} does not exist in LC attributes."
        }
    }

    End
    {

    }
}


<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PELCState
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    ) 
       
    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PE LC state information ..."
        try
        {
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_LCEnumeration -Namespace root\dcim -Filter "AttributeName='Lifecycle Controller State'"
        }
        catch
        {
            Write-Error -Message $_
        }
    }

    End
    {

    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER AttributeDisplayName
Parameter description

.PARAMETER GroupDisplayName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PESystemAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeDisplayName,

        [Parameter()]
        [String] $GroupDisplayName
    ) 
       
    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PE Systme attribute information ..."
        try
        {
            if ($AttributeDisplayName -and $GroupDisplayName)
            {

                $filter = "AttributeDisplayName='$AttributeDisplayName' AND GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($GroupDisplayName)
            {
                $filter = "GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($AttributeDisplayName)
            {
                $filter = "AttributeDisplayName='$AttributeDisplayName'"
            }
            else
            {
                $filter = $null
            }

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_SystemEnumeration -Namespace root\dcim -Filter $filter
        }
        catch
        {
            Write-Error -Message $_
        }
    }

    End
    {

    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PEFan
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process
    {
        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_FanView -Namespace root\dcim
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PECPU
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    process
    {
        $cpu = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_CPUView -Namespace root\dcim
        return $cpu
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PEPowerSupply
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process
    {
        $powerSupply = Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_PowerSupplyView -Namespace root\dcim
        return $powerSupply
    }
}

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
    [CmdletBinding(DefaultParameterSetName='General')]
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

        [Parameter(Mandatory)]
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

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PESystemRepositoryBasedUpdateList
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_SoftwareInstallationService";Name="DCIM:SoftwareUpdate";}
    $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
    $returnXml = [xml] (Invoke-CimMethod -InputObject $instance -MethodName GetRepoBasedUpdateList -CimSession $iDRACSession).PackageList

    $componentReport = @()
    foreach ($instance in $returnXml.Cim.MESSAGE.SIMPLEREQ.'VALUE.NAMEDINSTANCE'.INSTANCENAME)
    {
        $propertyHash = [Ordered] @{}
        $propertyHash.Add('ComponentName',$instance.PROPERTY.Where({$_.Name -eq 'DisplayName'}).Value)
        $propertyHash.Add('UpdateVersion',$instance.PROPERTY.Where({$_.Name -eq 'PackageVersion'}).Value)
        $propertyHash.Add('InstalledVersion',$instance.'Property.array'.Where({$_.Name -eq 'ComponentInstalledVersion'}).'Value.Array'.Value)
        $componentReport += $propertyHash
    }
    $componentReport
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER RebootJobType
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function New-PESystemRebootJob
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateSet(1,2,3)]
        [String] $RebootJobType
    
    )

    $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_SoftwareInstallationService";Name="DCIM:SoftwareUpdate";}
    $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
    $Parameters = @{
        RebootJobType = $RebootJobType
    }

    Invoke-CimMethod -InputObject $instance -MethodName CreateRebootJob -CimSession $iDRACSession -Arguments $Parameters
}


Export-ModuleMember -Function *
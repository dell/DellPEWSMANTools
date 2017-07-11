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
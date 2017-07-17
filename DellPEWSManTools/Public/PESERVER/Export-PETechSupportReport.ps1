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
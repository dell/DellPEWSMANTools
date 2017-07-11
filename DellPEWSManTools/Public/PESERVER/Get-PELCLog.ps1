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

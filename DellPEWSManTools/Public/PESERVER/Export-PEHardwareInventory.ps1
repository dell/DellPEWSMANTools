function Export-PEHardwareInventory {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory,
            ParameterSetName = 'General')]
        [Alias("s")]
        [Parameter(Mandatory,
            ParameterSetName = 'Passthru')]
        [Parameter(Mandatory,
            ParameterSetName = 'Wait')]
        [Parameter(Mandatory,
            ParameterSetName = 'Share')]
        [Parameter(Mandatory,
            ParameterSetName = 'ShareWait')]
        [Parameter(Mandatory,
            ParameterSetName = 'SharePassThru')]
        [Parameter(Mandatory,
            ParameterSetName = 'Local')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, ParameterSetName = 'General')]
        [Parameter(Mandatory, ParameterSetName = 'Passthru')]
        [Parameter(Mandatory, ParameterSetName = 'Wait')]
        [ValidateScript( { [System.Net.IPAddress]::TryParse($_, [ref]$null) })]
        [String]
        $IPAddress,

        [Parameter(Mandatory, ParameterSetName = 'General')]
        [Parameter(Mandatory, ParameterSetName = 'Passthru')]
        [Parameter(Mandatory, ParameterSetName = 'Wait')]
        [String]
        $ShareName,

        [Parameter(ParameterSetName = 'General')]
        [Parameter(ParameterSetName = 'Passthru')]
        [Parameter(ParameterSetName = 'Wait')]
        [Parameter(ParameterSetName = 'Share')]
        [Parameter(ParameterSetName = 'ShareWait')]
        [Parameter(ParameterSetName = 'SharePassThru')]
        [string]
        $FileName,

        [Parameter(ParameterSetName = 'General')]
        [Parameter(ParameterSetName = 'Passthru')]
        [Parameter(ParameterSetName = 'Wait')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet("NFS", "CIFS", "LOCAL")]
        [String]
        $ShareType = "CIFS",

        [Parameter(ParameterSetName = 'General')]
        [Parameter(ParameterSetName = 'Passthru')]
        [Parameter(ParameterSetName = 'Wait')]
        [PSCredential]
        $Credential,

        [Parameter(ParameterSetName = 'General')]
        [Parameter(ParameterSetName = 'Passthru')]
        [Parameter(ParameterSetName = 'Wait')]
        [Parameter(ParameterSetName = 'Share')]
        [Parameter(ParameterSetName = 'ShareWait')]
        [Parameter(ParameterSetName = 'SharePassThru')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet('CIM-XML', 'Simple')]
        [string]
        $XMLSchema = 'CIM-XML',

        [Parameter(Mandatory,
            ParameterSetName = 'SharePassThru')]
        [Parameter(Mandatory,
            ParameterSetName = 'ShareWait')]
        [Parameter(Mandatory,
            ParameterSetName = 'Share')]
        [Hashtable]
        $ShareObject,

        [Parameter(ParameterSetName = 'Local')]
        [Switch]
        $Passthru,

        [Parameter(ParameterSetName = 'Wait')]
        [Parameter(ParameterSetName = 'ShareWait')]
        [Parameter(ParameterSetName = 'Local')]
        [Switch]
        $Wait,

        [Parameter(ParameterSetName = 'Local')]
        [String]
        $LocalFilePath
    )

    Begin
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        if ($PSCmdlet.ParameterSetName -ne 'Local')
        {
            if ($ShareObject) 
            {
                $parameters = $ShareObject.Clone()
            } 
            else 
            {
                $parameters = @{
                    IPAddress = $IPAddress
                    ShareName = $ShareName
                    ShareType = ([ShareType]$ShareType -as [int])
                    XMLSchema = ([XMLSchema]$XMLSchema -as [int])
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

            if (-not $FileName) 
            {
                $FileName = "$($iDRACSession.Computername)-inventory.xml"
            }
            
            Write-Verbose "Hardware inventoy profile will be backed up as ${FileName}"
            $Parameters.Add('Filename',$FileName)            
        }
        else
        {
            $parameters = @{
                ShareType = ([ShareType]$ShareType -as [int])
                XMLSchema = ([XMLSchema]$XMLSchema -as [int])
            }
        }
    }

    Process 
    {
        $job = Invoke-CimMethod -InputObject $instance -MethodName ExportHWInventory -CimSession $iDRACSession -Arguments $Parameters
        if ($job.ReturnValue -eq 4096) 
        {
            if ($PSCmdlet.ParameterSetName -eq 'Local')
            {
                # Wait for the job to complete
                Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Exporting hardware inventory for $($iDRACSession.ComputerName)"

                # Export the job data
                $jobData = Export-PEJobData -iDRACSession $iDRACSession -ExportType 3
                if (!$Passthru)
                {
                    $jobData | Out-File -FilePath $LocalFilePath -Force -Verbose
                }
                else
                {
                    return $jobData    
                }
            }
            else
            {
                if ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Exporting hardware inventory for $($iDRACSession.ComputerName)"
                }    
            }
        } 
        else 
        {
            Throw "Job Creation failed with error: $($Job.Message)"
        }
    }
}

<#
Get-PELCLog.ps1 - GET PE LC log.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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

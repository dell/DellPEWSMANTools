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
Function Get-PEStorageController
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process 
    {
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_ControllerView' -Namespace 'root/dcim'
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
Function Get-PEVirtualDisk 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )
    
    Process
    {
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_VirtualDiskView' -Namespace 'root/dcim'
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER MediaType
Parameter description

.PARAMETER BusProtocol
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEPhysicalDisk
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [ValidateSet('HDD','SSD')]
        $MediaType,

        [Parameter()]
        [ValidateSet('Unknown','SCSI','PATA','FIBRE','USB','SATA','SAS','PCIe')]
        $BusProtocol
    )
    Process {
        if ($MediaType -and $BusProtocol)
        {
            $mediaInt = [int]([Disk.MediaType]$MediaType)
            $busProtocolInt = [int]([Disk.BusProtocol]$BusProtocol)
            $filter = "MediaType=$mediaInt AND BusProtocol=$BusProtocolInt"
        }
        elseif ($MediaType)
        {
            $mediaInt = [int]([Disk.MediaType]$MediaType)          
            $filter = "MediaType=$mediaInt"
        }
        elseif ($BusProtocol)
        {
            $busProtocolInt = [int]([Disk.BusProtocol]$BusProtocol)            
            $filter = "BusProtocol=$BusProtocolInt"
        }
        else
        {
            $filter = $null
        }

        Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_PhysicalDiskView -Namespace 'root/dcim' -Filter $filter
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER DiskType
Parameter description

.PARAMETER DiskProtocol
Parameter description

.PARAMETER DiskEncrypt
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEAvailableDisk
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        $DiskType,

        [Parameter()]
        $DiskProtocol,

        [Parameter()]
        $DiskEncrypt
    )

    Process 
    {
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_PhysicalDiskView' -Namespace 'root/dcim'
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
Function Get-PEEnclosure 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )
    Process
    {
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_EnclosureView' -Namespace 'root/dcim'
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER InstanceID
Parameter description

.PARAMETER RebootType
Parameter description

.PARAMETER StartTime
Parameter description

.PARAMETER UntilTime
Parameter description

.PARAMETER Force
Parameter description

.PARAMETER Wait
Parameter description

.PARAMETER Passthru
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Clear-PERAIDConfiguration 
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High",
        DefaultParameterSetName='General'
    )]

    param (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Passthru')]
        [Parameter(Mandatory, ParameterSetName='Wait')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        $InstanceID,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('None','PowerCycle','Graceful','Forced')]
        $RebootType = 'None',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $StartTime = 'TIME_NOW',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $UntilTime,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Switch] $Force,

        [Parameter(ParameterSetName='Wait')]
        [Switch] $Wait,

        [Parameter(ParameterSetName='Passthru')]
        [Switch] $Passthru
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }
    }

    Process 
    {
        if ($PSCmdlet.ShouldProcess($InstanceID, 'Clear Configuration')) 
        {
            $output = Invoke-CimMethod -InputObject $instance -MethodName ResetConfig -CimSession $idracsession -Arguments @{'Target'=$InstanceID}
            if ($output.ReturnValue -eq 0) 
            {
                if ($Output.RebootRequired -eq 'Yes') {
                    $RebootRequired = $true
                    if ($RebootType -eq 'None') 
                    {
                        Write-Warning 'A job will be scheduled but a reboot is required to complete the task. However, reboot type has been set to None. Manually power Cycle the target system to complete this job.'
                    } 
                    else 
                    {
                        Write-Warning "A job will be scheduled and a system reboot ($RebootType) will be initiated to complete the task"
                    }
                }
                else 
                {
                    $RebootRequired = $false
                    if ($RebootType -ne 'None') 
                    {
                        Write-Warning "System reboot is not required to complete the task. However, Reboot type is set to $RebootType. A reboot will be initiated to complete the task"
                    }
                }
            
                if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired -Passthru
                } 
                elseif ($PSCmdlet.ParameterSetName -eq 'Wait') 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired -Wait
                } 
                else 
                {
                    New-PETargetedConfigurationJob -iDRACSession $idracsession -InstanceID $InstanceID -StartTime $StartTime -UntilTime $UntilTime -RebootType $RebootType -RebootRequired $RebootRequired
                }
            }
            else 
            {
                $output
            }
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

.PARAMETER InstanceID
Parameter description

.PARAMETER RebootType
Parameter description

.PARAMETER RebootRequired
Parameter description

.PARAMETER JobType
Parameter description

.PARAMETER StartTime
Parameter description

.PARAMETER UntilTime
Parameter description

.PARAMETER Wait
Parameter description

.PARAMETER Passthru
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function New-PETargetedConfigurationJob 
{
    [CmdletBinding(DefaultParameterSetName='General')]

    param (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Passthru')]
        [Parameter(Mandatory, ParameterSetName='Wait')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        $InstanceID,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('None','PowerCycle','Graceful','Forced')]
        $RebootType = 'None',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Bool]$RebootRequired,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('Staged','Realtime')]
        [String] $JobType = 'Realtime',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $StartTime = 'TIME_NOW',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $UntilTime,

        [Parameter(ParameterSetName='Wait')]
        [Switch] $Wait,

        [Parameter(ParameterSetName='Passthru')]
        [Switch] $Passthru
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        $Parameters = @{
            Target = $InstanceID
            ScheduledStartTime = $StartTime
            Realtime = [Jobtype]$JobType -as [int]
        }

        if (-not ($RebootType -eq 'None')) 
        {
            $Parameters.Add('RebootJobType',([ConfigJobRebootType]$RebootType -as [int]))
        }

        if ($UntilTime) 
        {
            $Parameters.Add('UntilTime',$UntilTime)
        }
        $Parameters
    }

    Process 
    {
        $Job = Invoke-CimMethod -InputObject $instance -MethodName CreateTargetedConfigJob -CimSession $idracsession -Arguments $Parameters
        if ($Job.ReturnValue -eq 4096) 
        {
            if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
            {
                $Job
            } 
            elseif ($PSCmdlet.ParameterSetName -eq 'Wait') 
            {
                Write-Verbose 'Starting configuration job ...'
                Wait-PEConfigurationJob -JobID $Job.Job.EndpointReference.InstanceID -Activity 'Performing RAID Configuration ..'                
            }
        } 
        else 
        {
            Write-Error $Job.Message
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

.PARAMETER InstanceID
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Clear-PEForeignConfiguration 
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        $InstanceID
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
    }

    Process 
    {
        Invoke-CimMethod -InputObject $instance -MethodName ClearForeignConfig -CimSession $idracsession -Arguments @{'Target'=$InstanceID}
        New-PETargetedConfigurationJob -InstanceID $InstanceID -iDRACSession $iDRACSession
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER JobID
Parameter description

.PARAMETER StartTimeInterval
Parameter description

.PARAMETER UntilTime
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function New-PEJobQueue 
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        [string]$JobID,

        [Parameter()]
        [string]$StartTimeInterval ='TIME_NOW',

        [Parameter()]
        [string]$UntilTime
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="Idrac";CreationClassName="DCIM_JobService";Name="JobService";}
        $instance = New-CimInstance -ClassName DCIM_JobService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        $Parameters = @{
            JobArray = $JobID
            StartTimeInterval = $StartTimeInterval
        }

        if ($UntilTime) 
        {
            $Parameters.Add('UntilTime',$UntilTime)
        }
    }

    Process 
    {
        $Job = Invoke-CimMethod -InputObject $instance -MethodName SetupJobQueue -CimSession $idracsession -Arguments $Parameters
        $Job
        #if ($Job.ReturnValue -eq 0) {
        #    Write-Verbose "New job created with an ID - $($Job.Job.EndpointReference.InstanceID)"
        #} else {
        #    $Job
        #}
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER InstanceID
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Remove-PEVirtualDisk 
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        $InstanceID
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
    }

    Process 
    {
        Invoke-CimMethod -InputObject $instance -MethodName DeleteVirtualDisk -CimSession $idracsession -Arguments @{'Target'=$InstanceID}
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
function Get-PEPCIeSSDExtender
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process 
    {
        $ssdExtender = Get-CimInstance -ClassName DCIM_PCIeSSDExtenderView -Namespace root\dcim -CimSession $idracsession -Verbose
        return $ssdExtender
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
function Get-PEPCIeSSDBackPlane
{
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]

    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Process 
    {
        $ssdExtender = Get-CimInstance -ClassName DCIM_PCIeSSDBackPlaneView -Namespace root\dcim -CimSession $idracsession -Verbose
        return $ssdExtender
    }
}

Export-ModuleMember -Function *
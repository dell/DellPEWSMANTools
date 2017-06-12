<#
.Synopsis
   Gets the boot order set in a PowerEdge Server system.
.DESCRIPTION
   This cmdlet can be used to get the boot order a PowerEdge Server System.
   The boot sequence is displayed in the order of current assigned sequence.
.PARAMETER iDRACSession
    Specifies the CIM session object created for the PE Server System.
.EXAMPLE
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBootOrder -iDRACSession $iDRACSession
.INPUTS
   iDRACSession - CIM session with an iDRAC.
.OUTPUTS
   Boot Order obtained from DCIM_BootSourceSetting. 
#>
function Get-PEBootOrder
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        [Alias("s")]
        $iDRACSession
    )
    
    Process
    {
        Write-Verbose -Message "Getting boot order for $($iDRACSession.ComputerName) ..."
        Get-CimInstance -CimSession $iDRACSession -ResourceUri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_BootSourceSetting' -Namespace 'root/dcim'
    }
}

<#
.Synopsis
   Gets the PE BIOS attributes for a PowerEdge Server system.
.DESCRIPTION
   This cmdlet can be used to get a list of all possible BIOS attributes from a PowerEdge Server System.
   This can be used to retrieve the BIOS attributes from a specific group of attributes or just a single attribute.
.PARAMETER iDRACSession
   Specifies the CIM session object created for the PE Server System. 
.EXAMPLE
   The following example gets all PE BIOS attributes from a system.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession
.EXAMPLE  
   The following example gets all PE BIOS attributes from a system and within the Processor Settings group.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -GroupDisplayName 'Processor Settings'
.EXAMPLE  
   The following example gets a PE BIOS attribute from a system and within the Processor Settings group.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -GroupDisplayName 'Processor Settings' -AttributeDisplayName 'Number of Cores per Processor'  
.EXAMPLE  
   The following example gets a PE BIOS attribute from a system using the AttributeName parameter instead of AttributeDisplayName parameter.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName 'ProcCores'     
.INPUTS
   iDRACSession - CIM session with an iDRAC.
   AttributeName - Attribute name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
   AttributeDisplayName - Attribute display name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
   GroupDisplayName - Group display name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
.OUTPUTS
   Boot attribute information from the DCIM_BIOSEnumeration class.
#>
function Get-PEBIOSAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
                   )]
        [Alias("s")]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeDisplayName,

        [Parameter()]
        [String] $AttributeName,

        [Parameter()]
        [String] $GroupDisplayName
    ) 

    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PEBIOS attribute information ..."
        try
        {
            if ($AttributeDisplayName -and $AttributeName)
            {
                Write-Warning -Message 'Both AttributeName and AttributeDisplayName are specified. Only either of them will be used in the filter.'
            }

            if ($AttributeName -and $GroupDisplayName)
            {
                $filter = "AttributeName='$AttributeName' AND GroupDisplayName='$GroupDisplayName'"
            }
            elseif ($AttributeName)
            {
                $filter = "AttributeName='$AttributeName'"
            }
            elseif ($AttributeDisplayName -and $GroupDisplayName)
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

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_BIOSEnumeration -Namespace root\dcim -Filter $filter
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
This cmdlet gets the One Time boot setting from the system

.DESCRIPTION
The one time boot setting defines what has been configured as the next (one time) boot device. 
This cmdlet returns information about the one time boot setting.

.PARAMETER iDRACSession
Specifies the CIM session object created for the PE Server System. 

.EXAMPLE
An example

.INPUTS
   iDRACSession - CIM session with an iDRAC.

.OUTPUTS
    Returns a custom object with OneTimeBootMode and OneTimeBootModeDev as the keys.
#>
function Get-PESystemOneTimeBootSetting
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
                   )]
        [Alias("s")]
        $iDRACSession      
    )

    process
    {
        $oneTimeBootSetting = @{}
        $oneTimeBootMode = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName OneTimeBootMode
        $oneTimeBootSetting.Add('OneTimeBootMode',$oneTimeBootMode.CurrentValue)
        if ($oneTimeBootMode.CurrentValue -ne 'Disabled')
        {
            $oneTimeBootDevice = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName OneTimeUefiBootSeqDev
            $oneTimeBootSetting.Add('OneTimeBootDevice',$oneTimeBootDevice.CurrentValue)
        }

        return $oneTimeBootSetting
    }
}

<#
.SYNOPSIS
Sets PESystem One time boot setting.

.DESCRIPTION
Sets PE one time boot setting.

.EXAMPLE
An example

.INPUTS

.OUTPUTS
#>
function Set-PESystemOneTimeBootSetting
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
                   )]
        [Alias("s")]
        $iDRACSession,

        [Parameter()]
        [String] $OneTimeBootDevice       
    )

    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_BIOSService";Name="DCIM:BIOSService";}
        $instance = New-CimInstance -ClassName DCIM_BIOSService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    process
    {
        $possibleDevices = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName 'OneTimeUefiBootSeqDev' -Verbose
        if ($possibleDevices.PossibleValues -contains $OneTimeBootDevice)
        {
            $params = @{
                'Target'='BIOS.Setup.1-1'
                'AttributeName'=@('OneTimeBootMode','OneTimeUefiBootSeqDev')
                'AttributeValue'=@('OneTimeUefiBootSeq',$OneTimeBootDevice)
            }
            
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttributes -CimSession $session -Arguments $params
            if ($responseData.ReturnValue -eq 0)
            {
                Write-Verbose -Message 'One time boot mode configured successfully'
                if ($responseData.RebootRequired -eq 'Yes')
                {
                    Write-Verbose -Message 'One time boot mode change requires reboot.'
                }
            }
            else
            {
                Write-Warning -Message "One time boot mode change failed: $($responseData.Message)"
            }
        }
    }
}

function Set-PEBIOSAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
                   )]
        [Alias("s")]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeName,

        [Parameter()]
        [String[]] $AttributeValue        
    ) 

    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_BIOSService";Name="DCIM:BIOSService";}
        $instance = New-CimInstance -ClassName DCIM_BIOSService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        #Chekck if the attribute is settable.
        $attribute = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName $AttributeName -Verbose
        
        if ($attribute)
        {
            if ($attribute.IsReadOnly -eq 'false')
            {
                Write-Verbose "setting PEBIOS attribute information ..."

                #Check if the AttributeValue falls in the same set as the PossibleValues
                if ($attribute.PossiblesValues -contains $AttributeValue)
                {
                    try
                    {
                        $params = @{
                            'Target'         = 'BIOS.Setup.1-1'
                            'AttributeName'  = $AttributeName
                            'AttributeValue' = $AttributeValue
                        }

                        $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttribute -CimSession $session -Arguments $params
                        if ($responseData.ReturnValue -eq 0)
                        {
                            Write-Verbose -Message 'BIOS attribute configured successfully'
                            if ($responseData.RebootRequired -eq 'Yes')
                            {
                                Write-Verbose -Message 'BIOS attribute change requires reboot.'
                            }
                        }
                        else
                        {
                            Write-Warning -Message "BIOS attribute change failed: $($responseData.Message)"
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
            Write-Error -Message "${AttributeName} does not exist in PEBIOS attributes."
        }
    }

    End
    {

    }
}

function New-PESystemTargetedConfiguraionJob
{
    [CmdletBinding()]
    param (
        

    )
}

Export-ModuleMember -Function *
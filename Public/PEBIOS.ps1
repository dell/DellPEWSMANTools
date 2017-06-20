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
            
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttributes -CimSession $iDRACsession -Arguments $params
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

                #Check if the AttributeValue falls in the same set as the PossibleValues by calling the helper function
                if (TestPossibleValuesContainAttributeValues -PossibleValues $attribute.PossibleValues -AttributeValues $AttributeValue )
                {
                    try
                    {
                        $params = @{
                            'Target'         = 'BIOS.Setup.1-1'
                            'AttributeName'  = $AttributeName
                            'AttributeValue' = $AttributeValue
                        }

                        $responseData = Invoke-CimMethod -InputObject $instance -MethodName SetAttribute -CimSession $iDRACsession -Arguments $params
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
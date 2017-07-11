function Set-PEBIOSAttribute
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeName,

        [Parameter()]
        [String[]] $AttributeValue        
    ) 

    Begin
    {
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_BIOSService";Name="DCIM:BIOSService";}
        $instance = New-CimInstance -ClassName DCIM_BIOSService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set BIOS attribute'))
        {
            #Check if the attribute is settable.
            $attribute = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName $AttributeName -Verbose
            
            if ($attribute)
            {
                if ($attribute.IsReadOnly -eq 'false')
                {
                    Write-Verbose "setting PEBIOS attribute information ..."

                    #Check if the AttributeValue falls in the same set as the PossibleValues by calling the helper function
                    if (TestPossibleValuesContainAttributeValues -PossibleValues $attribute.PossibleValues -AttributeValues $AttributeValue )
                    {
                        if ($PSCmdlet.ShouldProcess($AttributeValue, 'Set BIOS attribute'))
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
    }

    End
    {

    }
}
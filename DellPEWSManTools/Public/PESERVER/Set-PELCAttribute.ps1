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
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='low')]
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
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set LC attribute'))
        {
            #Check if the attribute is settable.
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
    }

    End
    {

    }
}

<#
Set-PELCAttribute.ps1 - Sets PE system LC attribute.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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

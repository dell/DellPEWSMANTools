<#
Set-PEStandardSchemaSetting.ps1 - Sets schema setting in PE DRAC.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PEStandardSchemaSetting
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory=$true, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        # global Catalog Server Address 1
        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("gcsa1")]
        [String]
        $globalCatalogServerAddress1,

        # global Catalog Server Address 2
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("gcsa2")]
        [String]
        $globalCatalogServerAddress2,

        # global Catalog Server Address 3
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("gcsa3")]
        [String]
        $globalCatalogServerAddress3,

        # Wait for job completion
        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        # Privilege
        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties 
    
        $params=@{Target="iDRAC.Embedded.1"}

        $params.AttributeName=@()
        $params.AttributeValue=@()

        $params.AttributeName += "ActiveDirectory.1#GlobalCatalog1"
        $params.AttributeValue += $globalCatalogServerAddress1

        if ($globalCatalogServerAddress2) 
        {
            $params.AttributeName += "ActiveDirectory.1#GlobalCatalog2"
            $params.AttributeValue += $globalCatalogServerAddress2
        }

        if ($globalCatalogServerAddress3)
        {
            $params.AttributeName += "ActiveDirectory.1#GlobalCatalog3"
            $params.AttributeValue += $globalCatalogServerAddress3
        }
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'set Standard schema setting'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACsession -Arguments $params #2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACsession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring Standard Schema Settings for $($iDRACsession.ComputerName)"
                    Write-Verbose "Standard Schema Configured successfully"
                }
            } 
            else 
            {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }
        }
        
    }
}

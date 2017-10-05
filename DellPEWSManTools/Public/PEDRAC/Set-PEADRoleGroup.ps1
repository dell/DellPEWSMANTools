<#
Set-PEADRoleGroup.ps1 - Sets AD role group in PE DRAC.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PEADRoleGroup
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false,
                  SupportsShouldProcess=$true,
                  ConfirmImpact='low')]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        # Role Group Number
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateRange(1,5)]
        [Alias("rgn")]
		[Int]
        $roleGroupNumber,

        # Group Name
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("gn")]
		[String]
        $groupName,

        # Domain
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("dn")]
		[String]
        $domainName,

        # Privilege
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateRange(0,511)]
        [Alias("prv")]
		[int]
        $privilege,

        # Wait for job completion
        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        # Return the job object
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

        $group = "ADGroup." + $roleGroupNumber + "#"

        $blankInput = $true

        if ($groupName) 
        {
            $params.AttributeName += $group + "Name"
            $params.AttributeValue += $groupName
            $blankInput = $false
        }

        if ($domainName) 
        {
            $params.AttributeName += $group + "Domain"
            $params.AttributeValue += $domainName
            $blankInput = $false
        }

        if ($privilege) 
        {
            $params.AttributeName += $group + "Privilege"
            $params.AttributeValue += $privilege
            $blankInput = $false
        }

        if ($blankInput) 
        {
            Throw "ERROR: No arguments passed."
        }
    }
    Process 
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set AD Role group'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACsession -Arguments $params # 2>&1

            if ($responseData.ReturnValue -eq 4096)
                {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Applying Configuration Changes to AD RoleGroup for $($iDRACsession.ComputerName)"
                    Write-Verbose "AD Role Group Settings Successfully Applied"
                }
            } 
            else 
            {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }
        }
    }
    End
    {
    }
}

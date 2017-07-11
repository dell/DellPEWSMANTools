function Set-PEDRACUser
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
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        # user number 
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("unum")]
		[String]
        $userNumber,

        # Credential 
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("cred")]
		[PSCredential]
        [System.Management.Automation.Credential()]
        $credential,

        # user privilege 
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("priv")]
		[String]
        $privilege,

        # enable User
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("en")]
        [switch]
        $enable,

        # disable User
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("ds")]
        [switch]
        $disable,

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
        $password = $null
        $userName = $null
        if ($credential.GetNetworkCredential().UserName)
        {
            $userName = $credential.GetNetworkCredential().UserName
        }

        if ($credential.GetNetworkCredential().Password)
        {
            $password = $credential.GetNetworkCredential().Password
        }
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties 

        if ($enable -and $disable) 
        {
            Throw "ERROR: Enable and Disable cannot be done at the same time."
        }

        $params=@{Target="iDRAC.Embedded.1"}

        $params.AttributeName=@()
        $params.AttributeValue=@()

        $user = "Users." + $userNumber + "#"

        $blankInput = $true

        if ($userName) 
        {
            $params.AttributeName += $user + "UserName"
            $params.AttributeValue += $userName
            $blankInput = $false
        }

        if ($password) 
        {
            $params.AttributeName += $user + "Password"
            $params.AttributeValue += $password
            $blankInput = $false
        }

        if ($privilege) 
        {
            $params.AttributeName += $user + "Privilege"
            $params.AttributeValue += $privilege
            $blankInput = $false
        }

        if ($enable) 
        {
            $params.AttributeName += $user + "Enable"
            $params.AttributeValue += "Enabled"
            $blankInput = $false
        } 

        if ($disable) 
        {
            $params.AttributeName += $user + "Enable"
            $params.AttributeValue += "Disabled"
            $blankInput = $false
        }

        if ($blankInput) 
        {
            Throw "ERROR: No arguments passed."
        }
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName), 'invoke method ApplyAttributes'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACsession -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACsession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring iDRAC user for $($iDRACsession.ComputerName)"
                    Write-Verbose "iDRAC User configured successfully"
                }
            } else {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }
        }
        
    }
    End
    {
    }
}

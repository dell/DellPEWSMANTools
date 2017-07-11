function Set-PECommonADSetting
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory, 
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

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("udn")]
		[String]
        $userDomainName,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("dcsa1")]
		[String]
        $domainControllerServerAddress1,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("dcsa2")]
		[String]
        $domainControllerServerAddress2,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias("dcsa3")]
		[String]
        $domainControllerServerAddress3,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("ecv")]
        [switch]
        $enableCertificateValidation,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("dcv")]
        [switch]
        $disableCertificateValidation,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("ead")]
        [switch]
        $enableAD,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias ("dad")]
        [switch]
        $disableAD,

        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        if ($enableCertificateValidation -and $disableCertificateValidation) 
        {
            Throw "ERROR: Enable and Disable Certificate Validation cannot be true at the same time."
        }
    
        if ($enableAD -and $disableAD) 
        {
            Throw "ERROR: Enable and Disable Active Directory cannot be true at the same time."
        }
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties 

        $params=@{Target="iDRAC.Embedded.1"}

        $params.AttributeName=@()
        $params.AttributeValue=@()

        $blankInput = $true
    
        if ($enableCertificateValidation) 
        {
            $params.AttributeName += "ActiveDirectory.1#CertValidationEnable"
            $params.AttributeValue += "Enabled"
            $blankInput = $false
        } 

        if ($disableCertificateValidation) 
        {
            $params.AttributeName += "ActiveDirectory.1#CertValidationEnable"
            $params.AttributeValue += "Disabled"
            $blankInput = $false
        }
    
        if ($enableAD) 
        {
            $params.AttributeName += "ActiveDirectory.1#Enable"
            $params.AttributeValue += "Enabled"
            $blankInput = $false
        } 

        if ($disableAD) {
            $params.AttributeName += "ActiveDirectory.1#Enable"
            $params.AttributeValue += "Disabled"
            $blankInput = $false
        }


        if ($domainControllerServerAddress1) 
        {
            $params.AttributeName += "ActiveDirectory.1#DomainController1"
            $params.AttributeValue += $domainControllerServerAddress1
            $blankInput = $false
        }

        if ($domainControllerServerAddress2) 
        {
            $params.AttributeName += "ActiveDirectory.1#DomainController2"
            $params.AttributeValue += $domainControllerServerAddress2
            $blankInput = $false
        }

        if ($domainControllerServerAddress3) 
        {
            $params.AttributeName += "ActiveDirectory.1#DomainController3"
            $params.AttributeValue += $domainControllerServerAddress3
            $blankInput = $false
        }

        if ($blankInput) 
        {
            Throw "ERROR: No arguments passed."
        }
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName), 'Set common AD setting'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACSession -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Applying Configuration Changes to Comman AD Settings for $($iDRACsession.ComputerName)"
                    Write-Verbose "Changes to Common AD Settings applied successfully"
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

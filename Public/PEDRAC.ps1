function New-PEDRACSession
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimSession])]
    param (
        [Parameter (Mandatory)]
        [PSCredential] $Credential,

        [Parameter (Mandatory,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    ValueFromRemainingArguments=$false)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [string] $IPAddress,

        [Parameter()]
        [int] $MaxTimeout = 60
    )

    Begin
    {
        $cimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Creating iDRAC session..."
        try
        {
            $session = New-CimSession -Authentication Basic -Credential $Credential -ComputerName $IPAddress -Port 443 -SessionOption $cimOptions -OperationTimeoutSec $MaxTimeout -ErrorAction Stop
            if ($session)
            {
                $sysInfo = Get-PESystemInformation -iDRACSession $Session
                Add-Member -inputObject $Session -Name SystemGeneration -Value $([int](([regex]::Match($sysInfo.SystemGeneration,'\d+')).groups[0].Value)) -MemberType NoteProperty
                Add-Member -inputObject $Session -Name SystemType -Value $([regex]::Match($sysInfo.SystemGeneration,'(?<=\s).*').groups[0].Value) -MemberType NoteProperty
                return $session     
            }
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

function Get-PEDRACInformation
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession
    )

    Begin
    {
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PEDRAC information ..."
        try
        {
            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_iDRACCardView -Namespace root\dcim
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

function Get-PEDRACAttribute
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [String] $AttributeDisplayName,


        [String] $GroupDisplayName
    ) 
       
    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Retrieving PE DRAC attribute information ..."
        try
        {
            if ($AttributeDisplayName -and $GroupDisplayName)
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

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_iDRACCardAttribute -Namespace root\dcim -Filter $filter
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

Function Reset-PEDRAC 
{
    [CmdletBinding(SupportsShouldProcess=$true,
                ConfirmImpact='High',
                DefaultParameterSetName='General')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    Param
    (
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ParameterSetName='DRAC')]
        [Parameter(Mandatory, 
                   ParameterSetName='SSL')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()] 
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='DRAC')]
        [Parameter(ParameterSetName='SSL')]
        [Switch] $Force,

        [Parameter(ParameterSetName='DRAC')]
        [Switch] $DRACConfig,

        [Parameter(ParameterSetName='SSL')]
        [Switch] $SSLConfig,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='DRAC')]
        [ValidateSet('Graceful','Forced')]
        [String] $ResetType = 'Graceful'
    )
    
    Begin 
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }

        $Arguments = @{
            'Force' = [ResetType]$ResetType -as [int]
        }

        if ($pscmdlet.ParameterSetName -eq 'DRAC') 
        {
            $ResetMethod = 'iDRACResetCfg'    
        } 
        elseif ($pscmdlet.ParameterSetName -eq 'SSL') 
        {
            $ResetMethod = 'SSLResetCfg'
        } 
        else 
        {
            $ResetMethod = 'iDRACReset'
        }
    }

    Process
    {
        if ($pscmdlet.ShouldProcess($iDRACsession.ComputerName, $ResetMethod)) 
        {
            Write-Verbose "Performing ${ResetMethod} on the target system $($iDRACsession)"
            if ($pscmdlet.ParameterSetName -eq 'DRAC' -or $pscmdlet.ParameterSetName -eq 'General') 
            {
                $return = Invoke-CimMethod -InputObject $instance -CimSession $iDRACsession -MethodName $ResetMethod -Arguments $Arguments
            }
            else 
            {
                $return = Invoke-CimMethod -InputObject $instance -CimSession $iDRACsession -MethodName $ResetMethod
            }
            if ($return -ne 0) 
            {
                Write-Error $return.Message
            } 
            else 
            {
                Write-Verbose 'Reset initiated ...'
            }
        }
        
    }    
}

Function Get-PEDRACPrivilege 
{
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName='EncodeSpecial')]
        [ValidateSet('Admin','ReadOnly','Operator')]
        [String]$SpecialPrivilege,

        [Parameter(ParameterSetName='EncodeGroup')]
        [ValidateSet('Login','Configure','ConfigureUser','Logs','SystemControl','AccessVirtualConsole','AccessVirtualMedia','SystemOperation','Debug')]
        [String[]]$GroupedPrivilege,

        [Parameter(ParameterSetName='EncodeSpecial')]
        [Parameter(ParameterSetName='EncodeGroup')]
        [Switch]$Encode,

        [Parameter(ParameterSetName='Decode')]
        [Switch]$Decode,

        [Parameter(Mandatory,ParameterSetName='Decode')]
        [Int]$PrivilegeValue
    )

    Process 
    {
        if ($PSCmdlet.ParameterSetName -eq 'EncodeSpecial') 
        {
            [iDRAC.Privileges]$SpecialPrivilege -as [int]
        } 
        elseif ($PSCmdlet.ParameterSetName -eq 'EncodeGroup') 
        {
            $result = 0
            foreach ($privilege in $GroupedPrivilege) 
            {
                $result = $result -bor [iDRAC.Privileges]$privilege
            }
            $result
        } 
        else 
        {
            [iDRAC.Privileges]$PrivilegeValue
        }
    }
}

function Set-PEADRoleGroup
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
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
        $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACsession -Arguments $params 2>&1

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
    End
    {
    }
}

function Set-PECommonADSetting
{
    [CmdletBinding(DefaultParameterSetName='General')]
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
    End
    {
    }
}

function Set-PEDRACUser
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
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
    End
    {
    }
}

function Set-PEStandardSchemaSetting
{
    [CmdletBinding(DefaultParameterSetName='General')]
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
        $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $iDRACsession -Arguments $params 2>&1
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


function Get-PEADGroupInfo
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true, 
                   Position=0,
                   ParameterSetName='General')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
    }
    Process
    {
        
        Write-Verbose "Retrieving AD Group Information for $($iDRACsession.ComputerName)"
        $map = @{}
        $users = 1..5 | % {"ADGroup"+$_} 
        foreach ($user in $users)
        {
            $map.$user = @{"Privilege"="";"Domain"="";"Name"=""}
        }

        try
        {
            $responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardAttribute" -Namespace "root/dcim" -Query 'Select CurrentValue, InstanceID from DCIM_iDRACCardAttribute where  InstanceID like "%ADGroup.%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL" 2>&1

            foreach ($resp in $responseData){
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $entity = $resp.InstanceID.Split("#")[-1]
                    $currValue = $resp.CurrentValue
                    $key = "ADGroup"+$number
                    $map.$key.$entity = $currValue
                    }
            Write-Verbose "AD Group Information for $($iDRACsession.ComputerName) retrieved successfully"
            $map
        }
        catch
        {
            Throw "Could Not Retrieve AD Group Information for $($iDRACsession.ComputerName)"
        }
    }
}

function Get-PEDRACUser
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
    }
    Process
    {

        Write-Verbose "Retrieving iDRAC User Details for $($iDRACsession.ComputerName)"
        Try{
            $map = @{}
            $users = 1..16 | % {"User"+$_} 
            foreach ($user in $users)
            {
                $map.$user = @{"Privilege"="";"Enable"="";"UserName"=""}
            }

            $responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardString" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardString where InstanceID like "%#UserName"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.UserName = $currValue
            }


            $responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardInteger" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardInteger where InstanceID like "iDRAC.Embedded.1#Users%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.Privilege = $currValue
            }

            $responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardEnumeration" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardEnumeration where InstanceID like "iDRAC.Embedded.1#Users%" and InstanceID like "%#Enable"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.Enable = $currValue
            }
            Write-Verbose "iDRAC User Details for $($iDRACsession.ComputerName) retrieved successfully"

            $map
        } 

        Catch 
        {
            Throw "iDRAC User Details for $($iDRACsession.ComputerName) could not be retrieved"
        }
    }
}

function Import-PECertificate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
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

        # Pass phrase
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("pass")] 
        [string]
        $passphrase,

        # Certificate Filename
        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("cert")] 
        [string]
        $certificateFileName,

        # Web Server Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("wsc")] 
        [switch]
        $webServerCertificate,

        # AD Service Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("asc")] 
        [switch]
        $ADServiceCertificate,

        # Custom Signing Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("csc")] 
        [switch]
        $customSigningCertificate,

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

        $params=@{}

        if ( !$webServerCertificate -and !$ADServiceCertificate -and !$customSigningCertificate ) 
        {
            Throw "ERROR: Missing certificate type"
        }

        if ( ($webServerCertificate -and $ADServiceCertificate) -or ($ADServiceCertificate -and $customSigningCertificate) -or ($webServerCertificate -and $customSigningCertificate) ) 
        {
            Throw "ERROR: Cannot process multiple certificate types"
        }

    
        if ( $certificateFileName ) 
        {
            $data = Get-Content -Path $certificateFileName -Encoding String -Raw
            $certificate = [System.Convert]::ToBase64String( [System.Text.Encoding]::UTF8.GetBytes($data))

            if ( $certificate.Length -eq 0 ) 
            {
                Throw "ERROR: No certificate found in file specified"
            }
        }

        $params=@{}

        if ($certificate) 
        {
            $params.SSLCertificateFile = $certificate
        }

        if ($passphrase) 
        {
            $params.Passphrase = $passphrase
        }

        if ($webServerCertificate) 
        {
            $params.CertificateType = "1"
        }
        elseif ($ADServiceCertificate) 
        {
            $params.CertificateType = "2"
        } 
        else 
        {
            $params.CertificateType = "3"
        }
    }
    Process
    {

        Write-Verbose "Importing Certificate to $($iDRACsession.ComputerName)"
        $responseData = Invoke-CimMethod -InputObject $instance -MethodName ImportSSLCertificate -CimSession $iDRACsession -Arguments $params 2>&1
        if ($responseData.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $responseData
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACsession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring Standard Schema Settings for $($iDRACsession.ComputerName)"
                Write-Verbose "Imported Certificate to $($iDRACsession.ComputerName) successfully"
            }
        } 
        else 
        {
            Throw "Certificate Import to $($iDRACsession.ComputerName) failed with error: $($responseData.Message)"
        }
    }
}

Function Find-PEDRAC
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        #ipStartRange 
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias ("ips")]
        [String]
        $ipStartRange,

        # ipEndRange
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias ("ipe")]
        [String]
        $ipEndRange,
        
        # Credential
        [Parameter(Mandatory=$true, 
                   ParameterSetName='General')]
        [Alias ("cred")]
        [PSCredential]
        $credential,

        # Details switch
        [Parameter(ParameterSetName='General')]
        [Alias ("all")]
        [switch]
        $deepDiscover
    )
    
    Begin
    {
        function Find-PEDRAC_
        {
            [CmdletBinding(DefaultParameterSetName='General', 
                          PositionalBinding=$false)]
            [OutputType([String])]
            Param
            (
                #ipStartRange 
                [Parameter(Mandatory, 
                           ParameterSetName='General')]
                [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
                [Alias ("ips")]
                [String]
                $ipStartRange,

                # ipEndRange
                [Parameter(Mandatory, 
                           ParameterSetName='General')]
                [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
                [Alias ("ipe")]
                [String]
                $ipEndRange,
        
                # Credential
                [Parameter(Mandatory=$true, 
                           ParameterSetName='General')]
                [Alias ("cred")]
                [PSCredential]
                $credential,

                # Details switch
                [Parameter(ParameterSetName='General')]
                [Alias ("all")]
                [switch]
                $deepDiscover
            )

            Begin
            {
            }
            Process
            {
                if ($pscmdlet.ShouldProcess("iDRACs ", "Discover"))
                {
                    $start = $ipStartRange.split(".",4)[3]
                    $end = $ipEndRange.split(".",4)[3]
                    $firstthree = $ipStartRange.Remove($ipStartRange.LastIndexOf(".")) #xxx.xxx.xxx

                    $firstthreecheck = $ipEndRange.Remove($ipEndRange.LastIndexOf("."))

                    if ($firstthree -ne $firstthreecheck)
                    {
                        Write-Error "IP range is not correct"
                        return 0
                    }

                    $ipList = $start..$end | % {$firstthree+"."+$_} #get ip range
                    Write-Verbose "Total number of IPs = $($ipList.Count)"

                    $cmd = {
                    param($ip,$credential,$deepDiscover)
                    $finalresultList = @{}
                    $credential | ForEach-Object {
                        [xml]$result = ""
                        try{
                        [xml]$result = winrm id -u:$_.GetNetworkCredential().UserName -p:$_.GetNetworkCredential().Password -r:https://$ip/wsman -SkipCNCheck -SkipCACheck -encoding:utf-8 -a:basic -format:pretty 2>&1
          
                        if ($result.ChildNodes[0].ProductName -eq ("iDRAC") -or $result.ChildNodes[0].ProductName -eq("Integrated Dell Remote Access Controller")){
                                try
                                {
                                    $productName, $SystemType, $LCVersion, $iDRACVersion = $result.ChildNodes[0].ProductVersion.split(':')
                                    $SystemType = $SystemType.split('=')[1].Trim()
                                    $LCVersion = $LCVersion.split('=')[1].Trim()
                                    $iDRACVersion = $iDRACVersion.split('=')[1].Trim()
                                }
                                catch
                                {
                                    $productName, $SystemType, $LCVersion, $iDRACVersion = $null, $null, $null, $null
                                }
                                $finalresultList[$ip] = @{
                                                            #UserName = $_.GetNetworkCredential().UserName;
                                                            #Password = $_.GetNetworkCredential().Password;
                                                            ProductVersion = $result.ChildNodes[0].ProductVersion;
                                                            Product = $result.ChildNodes[0].ProductName;
                                                            SystemType = $SystemType;
                                                            LCVersion = $LCVersion;
                                                            iDRACVersion = $iDRACVersion
                                                         }
                                if ($deepDiscover)
                                {
                                    try
                                    {
                                        $session = New-PEDRACSession -IPAddress $ip -Credential $_
                                        $result2 = Get-PESystemInformation -iDRACSession $session 2>&1
                                        $finalresultList[$ip].add('ServiceTag',$result2.ServiceTag)
                                        $finalresultList[$ip].add('Model',$result2.Model)
                                        $finalresultList[$ip].add('PowerState',$result2.PowerState)
                                    }

                                    catch{
                                        Write-Error "$_"
                                    }
                                }
                                $finalresultList
                                break
                            } 
                        }
                        catch{}
                    } 
                    }
                    $jobs=@() 
                    $ipList | ForEach-Object {
                        $running = @(Get-Job | Where-Object { $_.State -eq 'Running' })
                        if ($running.Count -ge 10) 
                        {
                            $running | Wait-Job -Any | Out-Null
                        }
                        Write-Verbose "Discovering ip $_"      
                        $jobs += Start-Job -ScriptBlock $cmd -ArgumentList $_, $credential, $deepDiscover
                    } 
                    Wait-Job -Job $jobs | Out-Null 
                    Receive-Job -Job $jobs 
                }
            }
        }
        if( $Credential.GetNetworkCredential().UserName -eq $null)
        {
            Throw "Username cannot be empty"
        }
        if( $Credential.GetNetworkCredential().Password -eq $null)
        {
            Throw "Password cannot be empty"
        }        
    }
    Process
    {
            if ($deepDiscover)
            {
                $idracs = Find-PEDRAC_ -ipStartRange $ipStartRange -ipEndRange $ipEndRange -credential $credential -deepDiscover
            }
            else
            {
                $idracs = Find-PEDRAC_ -ipStartRange $ipStartRange -ipEndRange $ipEndRange -credential $credential
            }
            if ($idracs.Count -le 1)
            {
                $idracs
            }
            else
            {
                $idracMap=@{}
                for ($i=0; $i -lt $idracs.Count; $i++)
                {
                    [string]$ip = $idracs[$i].keys[0]
                    $idracMap.Add($ip,$idracs[$i][$ip])
                }
                $idracMap
            }
    }
}

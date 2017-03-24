<#
.Synopsis
   Creates a new CIM session for a Dell Remote Access Controller (DRAC)
.DESCRIPTION
   This function takes IPAddress and Credential as parameters and creates a new CIM Session for a DRAC. This function returns the iDRACSession.
.EXAMPLE
   The following example takes IP address strings as pipeline input and creates iDRACSessions and returns the session objects
   $iDRACSession = '10.10.10.120', '10.10.10.121', '10.10.10.122' | New-PEDRACSession -Credential (Get-Credential)

   #Use $iDRACSession with cmdlets
   Get-PESystemInformation -iDRACSession $iDRACSession
.EAMPLE
    The following example shows setting the timeout value for session creation to 120 seconds
    $Credential = Get-Credential
    New-PEDRACSession -IPAddress 10.10.10.121 -Credential $Credential -MaxTimeout 120
.INPUTS
   IPAddress - IP Address of the iDRAC
   Credential - Credentials to authenticate to iDRAC
   MaxTimeout - Sets the timeout value for creating the session. The default value is 60 seconds
.OUTPUTS
   Microsoft.Management.Infrastructure.CimSession
#>
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
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    }

    Process
    {
        Write-Verbose "Creating iDRAC session(s) ..."
        try
        {
            $Session = New-CimSession -Authentication Basic -Credential $Credential -ComputerName $IPAddress -Port 443 -SessionOption $CimOptions -OperationTimeoutSec $MaxTimeout -ErrorAction Stop
            return $Session
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
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
        $CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
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
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
        )]
        [Alias("s")]
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

            Get-CimInstance -CimSession $iDRACSession -ClassName DCIM_iDRACCardEnumeration -Namespace root\dcim -Filter $filter
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
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='DRAC')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='SSL')]
        [Alias("s")] 
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
        foreach ($session in $iDRACSession) 
        {
            if ($pscmdlet.ShouldProcess($Session.ComputerName, $ResetMethod)) 
            {
                Write-Verbose "Performing ${ResetMethod} on the target system $($Session)"
                if ($pscmdlet.ParameterSetName -eq 'DRAC' -or $pscmdlet.ParameterSetName -eq 'General') 
                {
                    $return = Invoke-CimMethod -InputObject $instance -CimSession $session -MethodName $ResetMethod -Arguments $Arguments
                }
                else 
                {
                    $return = Invoke-CimMethod -InputObject $instance -CimSession $session -MethodName $ResetMethod
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
}

<#
.Synopsis
   This cmdlets gets the DRAC privilge value from specified privilige string(s)
.DESCRIPTION
   This cmdlets gets the DRAC privilge value from specified privilige string(s)
.EXAMPLE
    The following example gets the special privilege value for the Operator privilege
    Get-PEDRACPrivilge -SpecialPrivilege Operator
.EXAMPLE
   The following example gets the grouped privilege value from a set of privilege strings
   
   Get-PEDRACPrivilege -GroupedPrivilege Login,Configure,SystemControl,AccessVirtualMedia
.INPUTS
    GroupedPrivilege - Specifies an array of string values from the set 'Login','Configure','ConfigureUser','Logs','SystemControl','AccessVirtualConsole','AccessVirtualMedia','SystemOperation','Debug'
    SpecialPrivilege - Specifies a single string value from the set 'Admin','ReadOnly','Operator'
#>
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

<#
.Synopsis
   Configures the Active Directory Role Group.
.DESCRIPTION
   The Set-PEADRoleGroup cmdlet creates the Active Directory Role Group or modifies an exisiting Active Directory Role Group.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The Role Group number needs to be given in order create or modify any or all of Group name, Domain name or Privilege.
   To know what privilege number needs to be set, use the Get-PEDRACPrivilege cmdlet.
   The cmdlet will Throw an error if the configuration fails.

.EXAMPLE
PS C:\Windows\system32> Set-PEADRoleGroup -session $iDRACSession -roleGroupNumber 1 -groupName ABC -domainName DOMAIN -privilege 511
True

   This command will configure the Active Directory Role Group with Group name ABC, Domain name DOMAIN and privilege 511

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER roleGroupNumber
Role Group Number.

.PARAMETER groupName
Group Name.

.PARAMETER domainName
Domain Name.

.PARAMETER privilege
Privilege level (0-511).

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.INPUTS
   iDRACSession, configuration parameters
#>
function Set-PEADRoleGroup
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNull()]
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
        foreach ($session in $iDRACSession) 
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $session -Arguments $params 2>&1

            if ($responseData.ReturnValue -eq 4096)
             {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $Session -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Applying Configuration Changes to AD RoleGroup for $($session.ComputerName)"
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

<#
.Synopsis
   Configures the common Active Directory settings.
.DESCRIPTION
   The Set-PECommonADSetting cmdlet configures the Active Directory .
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cmdlet can configure the user domain , domain controller server addresses.
   The cmdlet can either enable or disable the certificate validation.
   The cmdlet can either enable or disable the Active directory.
   The cmdlet will Throw an error if the configuration fails.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER userDomainName
User Domain Name.

.PARAMETER domainControllerServerAddress1
Domain Controller Server Ip Address 1.

.PARAMETER domainControllerServerAddress2
Domain Controller Server Ip Address 2.

.PARAMETER domainControllerServerAddress3
Domain Controller Server Ip Address 3.

.PARAMETER enableCertificateValidation
Enable Certificate Validation.

.PARAMETER disableCertificateValidation
Disable Certificate Validation.

.PARAMETER enableAD
Enable Active Directory.

.PARAMETER disableAD
Disable Active Directory.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -enableAD

This will enable Active Directory

.EXAMPLE
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -disableAD

This will disable Active Directory

.EXAMPLE
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -enableCertificateValidation -enableAD

This will enable Active Directory as well as enable Certificate Validation

.EXAMPLE
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -userDomainName <domainName>

This will set the user domain name to the value specified

.EXAMPLE
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -userDomainName <domainName> -domainControllerServerAddress1 <address1> -enableCertificateValidation -enableAD

This will set the user domain name and domain Controller Server Address 1 to the values specified, enable Active Directory and Certificate Validation

.INPUTS
   iDRACSession, configuration parameters
#>
function Set-PECommonADSetting
{
    [CmdletBinding(DefaultParameterSetName='General')]
    Param
    (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNull()]
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
        foreach ($session in $iDRACSession) 
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $session -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $Session -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Applying Configuration Changes to Comman AD Settings for $($session.ComputerName)"
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

<#
.Synopsis
   Configure an iDRAC user identified by the User number
.DESCRIPTION
   The Set-PEDRACUser cmdlet can create a new iDRAC user or modify the existing User using the Usernumber.
   The user can be enabled or disabled. Also the user privileges can be set.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The privilege number needs to be given in order to set the privilege for the user. To know what privilege number needs to be set, use the Get-PEDRACPrivilege cmdlet.
   
   The cmdlet will Throw an error if the configuration fails.
   
.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER userNumber
User Number.

.PARAMETER credential
Credential (Username and Password).

.PARAMETER privilege
Privilege level (0-511).

.PARAMETER enable
Enable the user.

.PARAMETER disable
Disable the user.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.


.EXAMPLE
PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 5 -enable
   This command will enable the user identified by iDRAC.Embedded.1#Users.5

.EXAMPLE
PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 5 -disable
   This command will disable the user identified by iDRAC.Embedded.1#Users.5

.EXAMPLE
 PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 3 -credential (Get-Credential) -privilege 511 -enable -wait
   This command will configure the user identified by iDRAC.Embedded.1#Users.3 with Username and Password as supplied in the get-credential prompt.
   This user is enabled and given full privileges. The cmdlet will wait for the job to complete.

.INPUTS
   iDRACSession, Configuration paremeters
#>
function Set-PEDRACUser
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNull()]
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
        foreach ($session in $iDRACSession) 
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $session -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $Session -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring iDRAC user for $($session.ComputerName)"
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

<#
.Synopsis
   Configures the Standard Schema settings.
.DESCRIPTION
   The Set-PEStandardSchemaSetting cmdlet configures the Standard Schema settings for Active Directory enablement.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cmdlet can configure either or all Global Catalog Server Addresses.
   The cmdlet will Throw an error if it fails to set the values.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER globalCatalogServerAddress1
Gloabl Catalog Server IP Address 1.

.PARAMETER globalCatalogServerAddress2
Gloabl Catalog Server IP Address 2.

.PARAMETER globalCatalogServerAddress3
Gloabl Catalog Server IP Address 3.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
   Set-Set-PEStandardSchemaSetting -session $iDRACSession -globalCatalogServerAddress1 $address1 -globalCatalogServerAddress2 $address2 -globalCatalogServerAddress3 $address3

   This command will configure the standard schema for the three addresses specified.

.INPUTS
   iDRACSession, configuration parameters
#>
function Set-PEStandardSchemaSetting
{
    [CmdletBinding(DefaultParameterSetName='General')]
    Param
    (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNull()]
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
        foreach ($session in $iDRACSession) 
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ApplyAttributes -CimSession $session -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $Session -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring Standard Schema Settings for $($session.ComputerName)"
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

<#
.Synopsis
   Gets the list of all AD Groups
.DESCRIPTION
   The Get-PEADGroupInfo cmdlet lists out details about all the AD Groups for the iDRAC specified. The output is a dictionary of AD Groups.
   The cmdlet will Throw an error if it fails to retrieve the information.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.EXAMPLE
   Get-PEADGroupInfo -session $iDRACSession
Name                           Value                                                                                                                                         
----                           -----                                                                                                                                         
ADGroup1                       {Domain, Name, Privilege}
ADGroup2                       {Domain, Name, Privilege}                                                                                                                     
ADGroup3                       {Domain, Name, Privilege}                                                                                                                     
ADGroup4                       {Domain, Name, Privilege}                                                                                                                     
ADGroup5                       {Domain, Name, Privilege}

   This command will show all the AD Groups and the values in a map which are Group Name, Domain and Privilege.
.EXAMPLE
     $adGroups = Get-PEADGroupInfo $iDRACSession

     $adGroups.ADGroup2

Name                           Value                                                                                                                                         
----                           -----                                                                                                                                         
Domain                                                                                                                                                                       
Name                                                                                                                                                                         
Privilege                      0                                     
        

   This command gets the hashmap in the variable $adGroups. $users.User2 lists the UserName, Enable and Privilege and its corresponding Values.
.EXAMPLE
     $adGroups = Get-PEADGroupInfo $iDRACSession

     $adGroups.ADGroup2.Privilege

     0                               

   This command gets the hashmap in the variable $adGroups. $adGroups.ADGroup2.Privilege outputs the Privilege for ADGroup2 which is 0.

.INPUTS
   iDRACSession
.OUTPUTS
   System.Object
   This command returns a Hashtable
#>
function Get-PEADGroupInfo
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
    }
    Process
    {
        if ( $iDRACSession.Count -gt 1 ) 
        {
            $mapofmap = @{}
        }

        foreach ($session in $iDRACSession) 
        {
            Write-Verbose "Retrieving AD Group Information for $($session.ComputerName)"
            $map = @{}
            $users = 1..5 | % {"ADGroup"+$_} 
            foreach ($user in $users)
            {
                $map.$user = @{"Privilege"="";"Domain"="";"Name"=""}
            }

            try
            {
                $responseData = Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardAttribute" -Namespace "root/dcim" -Query 'Select CurrentValue, InstanceID from DCIM_iDRACCardAttribute where  InstanceID like "%ADGroup.%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL" 2>&1

                foreach ($resp in $responseData){
                        $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                        $entity = $resp.InstanceID.Split("#")[-1]
                        $currValue = $resp.CurrentValue
                        $key = "ADGroup"+$number
                        $map.$key.$entity = $currValue
                        }
                Write-Verbose "AD Group Information for $($session.ComputerName) retrieved successfully"
                if ( $iDRACSession.Count -gt 1 ) 
                {
                    $mapofmap[$($session.ComputerName)]=$map.Clone()
                } 
                else 
                {
                    $map
                }
            }
            catch
            {
                Throw "Could Not Retrieve AD Group Information for $($session.ComputerName)"
            }
        }
        if ( $iDRACSession.Count -gt 1 ) 
        {
            $mapofmap
        }
    }
}

<#
.Synopsis
   Gets the list of all iDRAC users
.DESCRIPTION
   The Get-PEDRACUser cmdlet lists out all the iDRAC users for the session given. The output is a hashmap of users.
   The cmdlet will Throw an error if it fails to retrieve the information.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.


.EXAMPLE
   Get-PEDRACUser -session $iDRACSession
Name                           Value                                                                                             
----                           -----                                                                                             
User11                         {UserName, Enable, Privilege}                                                                     
User9                          {UserName, Enable, Privilege}                                                                     
User10                         {UserName, Enable, Privilege}                                                                     
User13                         {UserName, Enable, Privilege}                                                                     
User3                          {UserName, Enable, Privilege}                                                                     
User8                          {UserName, Enable, Privilege}                                                                     
User12                         {UserName, Enable, Privilege}                                                                     
User16                         {UserName, Enable, Privilege}                                                                     
User15                         {UserName, Enable, Privilege}                                                                     
User1                          {UserName, Enable, Privilege}                                                                     
User5                          {UserName, Enable, Privilege}                                                                     
User2                          {UserName, Enable, Privilege}                                                                     
User6                          {UserName, Enable, Privilege}                                                                     
User7                          {UserName, Enable, Privilege}                                                                     
User4                          {UserName, Enable, Privilege}                                                                     
User14                         {UserName, Enable, Privilege}                                                                     


   This command will show all the Users and the values in a map which are UserName, Enable and Privilege.
.EXAMPLE
     $users = Get-PEDRACUser $iDRACSession

     $users.User2

Name                           Value                                                                                             
----                           -----                                                                                             
UserName                       root                                                                                              
Enable                         Enabled                                                                                           
Privilege                      511                                   
        

   This command gets the hashmap in the variable $users. $users.User2 lists the UserName, Enable and Privilege and its corresponding Values.
.EXAMPLE
     $users = Get-PEDRACUser $iDRACSession

     $users.User2.Privilege

    511                               

   This command gets the hashmap in the variable $users. $users.User2.Privilege lists the Privilege for User2 which is 511.

.INPUTS
   iDRACSession
.OUTPUTS
   System.Object
   This command returns a Hashtable
#>
function Get-PEDRACUser
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
    }
    Process
    {
        if ( $iDRACSession.Count -gt 1 ) 
        {
            $mapofmap = @{}
        }
        
        foreach ($session in $iDRACSession)
        {
            Write-Verbose "Retrieving iDRAC User Details for $($session.ComputerName)"
            Try{
                $map = @{}
                $users = 1..16 | % {"User"+$_} 
                foreach ($user in $users)
                {
                    $map.$user = @{"Privilege"="";"Enable"="";"UserName"=""}
                }

                $responseData = Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardString" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardString where InstanceID like "%#UserName"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

                foreach ($resp in $responseData)
                {
                     $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                     $currValue = $resp.CurrentValue
                     $key = "User"+$number
                     $map.$key.UserName = $currValue
                }


                $responseData = Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardInteger" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardInteger where InstanceID like "iDRAC.Embedded.1#Users%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

                foreach ($resp in $responseData)
                {
                     $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                     $currValue = $resp.CurrentValue
                     $key = "User"+$number
                     $map.$key.Privilege = $currValue
                }

                $responseData = Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardEnumeration" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardEnumeration where InstanceID like "iDRAC.Embedded.1#Users%" and InstanceID like "%#Enable"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"

                foreach ($resp in $responseData)
                {
                     $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                     $currValue = $resp.CurrentValue
                     $key = "User"+$number
                     $map.$key.Enable = $currValue
                }
                Write-Verbose "iDRAC User Details for $($session.ComputerName) retrieved successfully"

                if ( $iDRACSession.Count -gt 1 ) 
                {
                    $mapofmap[$($session.ComputerName)]=$map.Clone()
                } 
                else 
                {
                    $map
                }
            } 

            Catch 
            {
                Throw "iDRAC User Details for $($session.ComputerName) could not be retrieved"
            }
        }
        if ( $iDRACSession.Count -gt 1 ) 
        {
            $mapofmap
        }
    }
}

<#
.Synopsis
   Imports a Certificate.
.DESCRIPTION
   The Import-Certificate cmdlet imports the certificate given by the certificatefilename.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cetificateFileName is the path to the Certificate file. A passphrase may or may not be required depending on the certificate.
   The cmdlet can import either the WebServer Certificate or AD Service Certificate or the Custom Signing Certificate.
   The cmdlet will Throw an error if the import fails.

.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER certificateFileName
The complete path to the certificate file.

.PARAMETER passphrase
Passphrase for the certificate file.

.PARAMETER webServerCertificate
Option to identify the certificate as webServerCertificate.

.PARAMETER ADServiceCertificate
Option to identify the certificate as ADServiceCertificate.

.PARAMETER customSigningCertificate
Option to identify the certificate as customSigningCertificate.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
   Import-PECertificate -session $iDRACSession -certificateFileName $certfile -passphrase pass -customSigningCertificate 


   This command will import the Custom Signing Certificate for the specified iDRAC using the passphrase pass

.INPUTS
   iDRACSession, certificateFileName, passphrase, certificateType(as option)
 #>
function Import-PECertificate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNull()]
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
        foreach ($session in $iDRACSession)
        {
            Write-Verbose "Importing Certificate to $($session.ComputerName)"
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName ImportSSLCertificate -CimSession $session -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $Session -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring Standard Schema Settings for $($session.ComputerName)"
                    Write-Verbose "Imported Certificate to $($session.ComputerName) successfully"
                }
            } 
            else 
            {
                Throw "Certificate Import to $($session.ComputerName) failed with error: $($responseData.Message)"
            }
        }
    }
}

<#
.Synopsis
   Discovers all iDRACs and return a hashmap contained the discovered iDRACs.
.DESCRIPTION
   The Find-PEDRAC cmdlet accepts a range of IP addresses and up to three Username,Password lists. The IP start range and end range is a mandatory parameter. Atlease one Username and password list is required for the cmdlet.
   The cmdlet returns a hashtables where, the IP address is the key and its value is another hashtable with the system product information as the key/value pairs. 

.PARAMETER ipStartRange
Starting IP of the range.

.PARAMETER ipEndRange
Ending IP of the range.

.PARAMETER credential
a PSCredential object, will prompt for credential if kept blank.

.PARAMETER deepDiscover
This parameter returns additional details for each discovered server, including Service Tag, Model, and Power State.

.EXAMPLE
PS C:\Windows\system32> $dracs = Find-PEDRAC -ipStartRange 192.168.0.1 -ipEndRange 192.168.0.10 -credential (Get-Credential) -deepDiscover
    
This command returns a hashmap containing all discovered IPs into $drac with IP address as key. The contents of the hashtable will depend on the -deepDiscover switch.

.INPUTS
   ipStartRange, ipEndRange, credential, deepDiscover(optional)
.OUTPUTS
   System.Object
   This command returns a Hashtable
#>
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

Export-ModuleMember -Function *
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PEDriverPackInformation {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Begin {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process {
        $result = Invoke-CimMethod -InputObject $instance -MethodName GetDriverPackInfo -CimSession $iDRACSession
        if ($result.ReturnValue -ne 0) 
        {
            Write-Error $result.Message
        } 
        else 
        {
            $result
        }
    }
}

#Function Attach-PEDriverPack {
#    [CmdletBinding()]
#    Param (
#        [Parameter(Mandatory, 
#                   ValueFromPipeline=$true,
#                   ValueFromPipelineByPropertyName=$true, 
#                   ValueFromRemainingArguments=$false
#        )]
#        [Alias("s")]
#        $iDRACSession,
#
#        [Parameter(Mandatory)]
#        [String] $OSName,
#
#        [Parameter()]
#        [int] $Duration
#    )
#
#    Begin {
#        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
#        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
#    }
#
#    Process {
#        $argumentHash = @{'OSName'="$OSName"}
#        if ($Duration)
#        {
#            $argumentHash.Add('Duration',$Duration)
#        }
#
#        $result = Invoke-CimMethod -InputObject $instance -MethodName UnpackAndAttach -Arguments $argumentHash -CimSession $iDRACSession
#        if ($result.ReturnValue -ne 0) {
#            Write-Error $result.Message
#        } else {
#            $result
#        }
#    }
#}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-PEBootToPXE
{
    [CmdletBinding(SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession    
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set boot to PXE'))
        {
            $result = Invoke-CimMethod -InputObject $instance -MethodName BootToPXE -CimSession $iDRACSession
            if ($result.ReturnValue -ne 0) 
            {
                Write-Error $result.Message
            } 
            else 
            {
                $result
            }   
        }
             
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-PEBootToHD
{
    [CmdletBinding(SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession    
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set Boot to HD'))
        {
            $result = Invoke-CimMethod -InputObject $instance -MethodName BootToHD -CimSession $iDRACSession
            if ($result.ReturnValue -ne 0) 
            {
                Write-Error $result.Message
            } 
            else 
            {
                $result
            }
        }
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PEHostMACInformation
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession    
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        $result = Invoke-CimMethod -InputObject $instance -MethodName GetHostMACInfo -CimSession $iDRACSession
        if ($result.ReturnValue -ne 0) 
        {
            Write-Error $result.Message
        } 
        else 
        {
            $result
        }        
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER IPAddress
Parameter description

.PARAMETER ShareName
Parameter description

.PARAMETER ImageName
Parameter description

.PARAMETER Credential
Parameter description

.PARAMETER ShareType
Parameter description

.PARAMETER HashType
Parameter description

.PARAMETER HashValue
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Connect-PERFSISOImage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
        
        [Parameter(Mandatory)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String]$ShareName,

        [Parameter(Mandatory)]
        [String]$ImageName,

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter()]
        [ValidateSet("NFS","CIFS")]
        [String]$ShareType = "CIFS",
        
        [Parameter(Mandatory)]
        [ValidateSet('MD5','SHA1')]
        [String] $HashType,

        [Parameter(Mandatory)]
        [String] $HashValue
    )   

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        $params= @{
            IPAddress = $IPAddress
            ShareName = $ShareName
            ShareType = ([ShareType]$ShareType -as [int])
            ImageName = $ImageName
            Username = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
            HashType = ([HashType]$HashType -as [int])
            HashValue = $HashValue
        }

        Invoke-CimMethod -InputObject $instance -CimSession $iDRACSession -MethodName ConnectRFSISOImage -Arguments $params -Verbose
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PERFSISOImageConnectionInformation
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        Invoke-CimMethod -InputObject $instance -CimSession $iDRACSession -MethodName GetRFSISOImageConnectionInfo -Verbose
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-PENetworkISOImageConnectionInformation
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        Invoke-CimMethod -InputObject $instance -CimSession $iDRACSession -MethodName GetNetworkISOImageConnectionInfo -Verbose
    }
}

Export-ModuleMember -Function *
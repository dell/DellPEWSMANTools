Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory)]
        [String] $Id,
        
        [Parameter(Mandatory)]
        [String] $DRACIPAddress, 

        [Parameter(Mandatory)]
        [PSCredential] $DRACCredential
    )

    $configuration = @{
        Id = $Id
        DRACIPAddress = $DRACIPAddress
        DRACCredential = $DRACCredential
    }

    try
    {
        Write-Verbose -Message 'Creating a CIM session to iDRAC'
        $dracSession = New-PEDRACSession -IPAddress $DRACIPAddress -Credential $DRACCredential
        $oneTimeBoot =  Get-PESystemOneTimeBootSetting -iDRACSession $dracSession
        if ($oneTimeBoot)
        {
            if ($oneTimeBoot.OneTimeBootMode -eq 'Enabled')
            {
                Write-Verbose -Message 'One time boot mode is enabled'
                $configuration.Add('OneTimeBootMode','Enabled')          
                $configuration.Add('OneTimeBootDevice',$oneTimeBoot.OneTimeBootDevice)
            }
            else
            {
                $configuration.Add('OneTimeBootMode','Disabled') 
            }
        }
        return $configuration
    }
    catch
    {
        Write-Error $_
    }
}

Function Set-TargetResource
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [String] $Id,
        
        [Parameter(Mandatory)]
        [String] $DRACIPAddress, 

        [Parameter(Mandatory)]
        [PSCredential] $DRACCredential,

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        [String] $OneTimeBootMode = 'Disabled',

        [Parameter()]
        [String] $OneTimeBootDevice
    )

    if ($OneTimeBootMode -eq 'Enabled' -and (-not $OneTimeBootDevice))
    {
        throw 'OneTimeBootDevice cannot be null when OneTimeBootMode is set to Enabled.'
    }

    if ($OneTimeBootMode -eq 'Disabled' -and $OneTimeBootDevice)
    {
        Write-Warning -Message 'Ignoring OneTimeBootDevice since OneTimeBootMode is set to Disabled.'
    }

    Write-Verbose -Message 'Creating a CIM session to iDRAC'
    $dracSession = New-PEDRACSession -IPAddress $DRACIPAddress -Credential $DRACCredential
    $oneTimeBoot =  Get-PESystemOneTimeBootSetting -iDRACSession $dracSession

    if ($OneTimeBootMode -eq 'Enabled')
    {
        Write-Verbose -Message 'OneTimeBootMOde is set to Disabled and it will be enabled.'
        Set-PESystemOneTimeBootSetting -iDRACSession $dracSession -OneTimeBootDevice $OneTimeBootDevice -Verbose
    }
    else
    {
        Write-Verbose -Message 'OneTimeBootMode will be set to Disabled.'
        Set-PEBIOSAttribute -AttributeName OneTimeBootMode -AttributeValue Disabled -Verbose
    }
}

Function Test-TargetResource 
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [String] $Id,
        
        [Parameter(Mandatory)]
        [String] $DRACIPAddress, 

        [Parameter(Mandatory)]
        [PSCredential] $DRACCredential,

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        [String] $OneTimeBootMode = 'Disabled',

        [Parameter()]
        [String] $OneTimeBootDevice
    )

    if ($OneTimeBootMode -eq 'Enabled' -and (-not $OneTimeBootDevice))
    {
        throw 'OneTimeBootDevice cannot be null when OneTimeBootMode is set to Enabled.'
    }

    if ($OneTimeBootMode -eq 'Disabled' -and $OneTimeBootDevice)
    {
        Write-Warning -Message 'Ignoring OneTimeBootDevice since OneTimeBootMode is set to Disabled.'
    }

    Write-Verbose -Message 'Creating a CIM session to iDRAC'
    $dracSession = New-PEDRACSession -IPAddress $DRACIPAddress -Credential $DRACCredential
    $oneTimeBoot =  Get-PESystemOneTimeBootSetting -iDRACSession $dracSession

    if ($OneTimeBootMode -eq 'Enabled')
    {
        if ($oneTimeBoot.OneTimeBootMode -eq 'OneTimeUefiBootSeq')
        {
            Write-Verbose -Message 'OneTimeBootMode attribute is already set to Enabled'
            if ($oneTimeBoot.OneTimeBootDevice -ne $OneTimeBootDevice)
            {
                Write-Verbose -Message 'OneTimeBootDevice attribute is not matching. This will be changed.'
                return $false
            }
            else
            {
                Write-Verbose -Message 'OneTimeBootDevice attribute is configured as needed. No action needed.'                
                return $true
            }
        }
        else
        {
            Write-Verbose -Message 'OneTimeBootMode is not enabled. This will be changed.'
            return $false
        }
    }
    else
    {
        if ($oneTimeBoot.OneTimeBootMode -eq 'OneTimeUefiBootSeq')
        {
            Write-Verbose -Message 'OneTimeBootMode attribute is set to OneTimeUefiBootSeq. This will be changed.'
            return $false
        }
        else
        {
            Write-Verbose -Message 'OneTimeBootMode is Disabled. No action needed.'
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
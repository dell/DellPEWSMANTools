<#
.Synopsis
   This cmdletis a helper function that can be used to generate a hash table of properties
.DESCRIPTION
   This cmdletis a helper function that can be used to generate a hash table of properties and optionally validate if the share is accessible from iDRAC
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   Using the default iDRAC session, you can validate and generate the share object
   Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential) -ShareType NFS -Validate
.EXAMPLE
   The following example generates the share object without validation
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationShare -IPAddress 10.10.10.100 -ShareName Config -Credential (Get-Credential)
.INPUTS
    iDRACSession - CIM session with an iDRAC
    IPAddress - IPAddress of the share
    ShareName - Name of the network share
    ShareType - type of share (NFS/CIFS)
    Credential - Credentials to access the network share
    Validate - Validate if the share is accessible from iDRAC or not
#>
Function Get-PEConfigurationShare 
{
    [CmdletBinding()]
    [OutputType([System.Collections.HashTable])]
    Param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String]$ShareName,

        [Parameter()]
        [ValidateSet('NFS','CIFS')]
        [String]$ShareType = "CIFS",

        [Parameter()]
        [PSCredential]$Credential,

        [Parameter()]
        [Switch]$Validate
    )
    
    Begin 
    {
        $Parameters = @{
            IPAddress = $IPAddress
            ShareName = $ShareName
            ShareType = [ShareType]$ShareType -as [int]
        }

        if ($Credential) 
        {
            $Parameters.Add('Username',$Credential.GetNetworkCredential().UserName)
            $Parameters.Add('Password',$Credential.GetNetworkCredential().Password)
            if ($Credential.GetNetworkCredential().Domain) 
            {
                $Parameters.Add('Workgroup',$Credential.GetNetworkCredential().Domain)
            }
        }

        if ($Validate) 
        {
            $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
            $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        }
    }

    Process 
    {
        If ($Validate) 
        {
            Write-Verbose 'Testing if the share is accessible from iDRAC'
            $Job = Invoke-CimMethod -InputObject $instance -MethodName TestNetworkShare -CimSession $iDRACSession -Arguments $Parameters
            if (-not ($job.ReturnValue -eq 0)) 
            {
                Write-Error $Job.Message
            } 
            else 
            {
                Write-Verbose 'Share access validation is completed successfully'
                $Parameters
            }
        } 
        else
        {
            Write-Verbose 'No share access validation requested. Returning the hashtable.'
            $Parameters
        }
    }
}
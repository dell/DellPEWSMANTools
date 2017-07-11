Function Get-PEDRACPrivilege 
{
    [CmdletBinding()]
    [OutputType([int])]
    # Suppressing this for now, since there are 2 types of output
    # This needs to be refactored -> https://github.com/rchaganti/DellPEWSMANTools/issues/21
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly',
        '', Scope='Function')]
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
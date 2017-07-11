function Get-PESystemOneTimeBootSetting
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession      
    )

    Process
    {
        $oneTimeBootSetting = @{}
        $oneTimeBootMode = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName OneTimeBootMode
        $oneTimeBootSetting.Add('OneTimeBootMode',$oneTimeBootMode.CurrentValue)
        if ($oneTimeBootMode.CurrentValue -ne 'Disabled')
        {
            $oneTimeBootDevice = Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName OneTimeUefiBootSeqDev
            $oneTimeBootSetting.Add('OneTimeBootDevice',$oneTimeBootDevice.CurrentValue)
        }

        return $oneTimeBootSetting
    }
}

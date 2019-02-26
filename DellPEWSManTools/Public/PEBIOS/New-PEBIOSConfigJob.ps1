function New-PEBIOSConfigJob
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter()]
        [ValidateSet(1,2,3)]
        [Int]
        $RebootType = 1,

        [Parameter()]
        [String]
        $ScheduledStartTime = 'TIME_NOW',

        [Parameter()]
        [String]
        $UntilTime
    )

    Begin
    {
        #$CimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_BIOSService";Name="DCIM:BIOSService";}
        $instance = New-CimInstance -ClassName DCIM_BIOSService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Set BIOS attribute'))
        {
            $params = @{
                'Target'             = 'BIOS.Setup.1-1'
                'RebootType'         = $RebootType
                'ScheduledStartTime' = $ScheduledStartTime
            }

            if ($UntilTime)
            {
                $params.Add('UntilTime', $UntilTime)
            }

            $responseData = Invoke-CimMethod -InputObject $instance -MethodName CreateTargetedConfigJob -CimSession $iDRACsession -Arguments $params

            if ($responseData.ReturnValue -eq 4096)
            {
                return $responseData
            }

            return $responseData
        }
    }
}

Function Get-PEDriverPackInformation {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false
        )]
        [Alias("s")]
        $iDRACSession
    )

    Begin {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_OSDeploymentService";Name="DCIM:OSDeploymentService";}
        $instance = New-CimInstance -ClassName DCIM_OSDeploymentService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    }

    Process {
        foreach ($session in $iDRACSession) {
            $result = Invoke-CimMethod -InputObject $instance -MethodName GetDriverPackInfo -CimSession $iDRacsession
            if ($result.ReturnValue -ne 0) {
                Write-Error $result.Message
            } else {
                $result
            }
        }
    }
}

Export-ModuleMember -Function *
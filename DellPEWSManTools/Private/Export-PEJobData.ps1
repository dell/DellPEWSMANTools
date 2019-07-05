<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER ExportType
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function Export-PEJobData
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory = $true)]
        $ExportType
    )

    $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
    $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
    
    $parameters = @{
        FileType = $ExportType
        TxDataSize = '0'
        FileOffset = '0'
        InChunkSize = '3333'
        InSessionID = ''
    }
    
    $data = Invoke-CimMethod -InputObject $instance -MethodName ExportData -CimSession $iDRACSession -Arguments $parameters
    
    $payload = ''
    while (($data.TxfrDescriptor -eq 1) -or ($data.TxfrDescriptor -eq 2))
    {    
        $payload += $data.Payload
        $parameters = @{
            FileType = $ExportType
            TxDataSize = $data.RetTxDataSize
            FileOffset = $data.RetFileOffset
            InChunkSize = '3333'
            InSessionID = $data.SessionID
        }
        $data = Invoke-CimMethod -InputObject $instance -MethodName ExportData -CimSession $iDRACSession -Arguments $parameters
    }
    
    $payload += $data.Payload
    
    $configFile = [System.Convert]::FromBase64String($payload)
    $convertedString = [System.Text.Encoding]::UTF8.GetString($configFile)

    return $convertedString
}

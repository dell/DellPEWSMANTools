<#
.Synopsis
   This cmdlets provides detailed results from of a job object
.DESCRIPTION
   This cmdlets provides detailed results from of a job object
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The JobID String must have a value representing JOB ID from the LC job queue.
   Get-PEConfigurationResult -JobID 'JobID String'
.EXAMPLE
   The following example creates an iDRAC session
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Get-PEConfigurationResult -JobID 'JobID String' -iDRACSession $iDRACSession
.INPUTS
    iDRACSession - CIM session with an iDRAC
    JobID - JobID string from the job queue
#>
Function Get-PEConfigurationResult
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,
    
        [Parameter(Mandatory)]
        $JobID
    )

    Begin 
    {
        $properties=@{InstanceID="DCIM:LifeCycleLog";}
        $instance = New-CimInstance -ClassName DCIM_LCRecordLog -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $Parameters = @{
            JobID = $JobID
        }
    }

    Process 
    {
        $Result = Invoke-CimMethod -InputObject $instance -MethodName GetConfigResults -CimSession $iDRACSession -Arguments $Parameters
        if ($Result.ReturnValue -eq 0) 
        {
            $Xml = $Result.COnfigResults
            $XmlDoc = New-Object System.Xml.XmlDocument
            $ConfigResults = $XmlDoc.CreateElement('Configuration')
            $ConfigResults.InnerXml = $Xml
            Foreach ($ConfigResult in $ConfigResults.ConfigResults) 
            {
                $ResultHash = [Ordered]@{
                    JobName = $ConfigResult.JobName
                    JobID = $ConfigResult.JobID
                    JobDisplayName = $ConfigResult.JobDisplayName
                    FQDD = $ConfigResult.FQDD
                }
                $OperationArray = @()
                Foreach ($Operation in $ConfigResult.Operation) 
                {
                    $OperationHash = [Ordered]@{
                        Name = $Operation.Name -join ' - '
                        DisplayValue = $Operation.DisplayValue
                        Detail = $Operation.Detail.NewValue
                        MessageID = $Operation.MessageID
                        Message = $Operation.Message
                        Status = $Operation.Status
                        ErrorCode = $Operation.ErrorCode
                    }
                    $OperationArray += $OperationHash      
                }
                $ResultHash.Add('Operation',$OperationArray)
                New-Object -TypeName PSObject -Property $ResultHash
            }
        } 
        else 
        {
            Write-Error $Result.Message
        }
        
    }
}
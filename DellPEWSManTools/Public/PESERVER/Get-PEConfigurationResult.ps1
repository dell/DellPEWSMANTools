<#
Get-PEConfigurationResult.ps1 - GET PE configuration job result.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
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
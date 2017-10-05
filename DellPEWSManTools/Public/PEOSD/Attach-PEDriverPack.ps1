<#
Attach-PEDriverPack.ps1 - Attach a PE driver pack.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
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

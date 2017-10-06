<#
Add-PELCLogComment.ps1 - Adds a comment to the LC log.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Add-PELCLogComment
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        $iDRACSession,

        [Parameter(Mandatory)]
        [ValidateLength(1,255)]
        [string] $Comment,

        [Parameter()]
        [uint32] $LogSequenceNumber
    )

    $parameters = @{
            comment = $Comment
    }

    if ($LogSequenceNumber)
    {
        Write-Verbose -Message 'Adding a LC log comment ..'
        $parameters.Add('LogSequenceNumber', $LogSequenceNumber)        
    }
    else
    {
        Write-Verbose -Message 'Adding the comment as work notes ..'    
    }

    $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
    $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

    Invoke-CimMethod -InputObject $instance -MethodName InsertCommentInLCLog -CimSession $iDRACSession -Arguments $parameters
}
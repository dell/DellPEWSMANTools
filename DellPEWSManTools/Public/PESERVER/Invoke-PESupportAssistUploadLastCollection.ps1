<#
Invoke-PESupportAssistUploadLastCollection.ps1 - Cmdlet to Upload last SupportAssist collection (Stored on idrac) and send to Dell SA Backend Server.

_author_ = Kristian Lamb <Kristian.Lamb@Dell.com> _version_ = 1.0

Copyright (c) 2019, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Invoke-PESupportAssistUploadLastCollection
{
  [CmdletBinding(DefaultParameterSetName='General')]
  Param
  (
      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [Alias("s")]
      [ValidateNotNullOrEmpty()]
      $iDRACSession,

      [Parameter(ParameterSetName='General')]
      [Switch]$Passthru,

      [Parameter(ParameterSetName='General')]
      [Switch]$Wait
  )

  Begin
  {
      $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
      $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
  }

  Process
  {

      $job = Invoke-CimMethod -InputObject $instance -MethodName SupportAssistUploadLastCollection -CimSession $iDRACSession -Arguments $Parameters

      if ($job.ReturnValue -eq 4096)
      {
          if ($Passthru)
          {
              $job
          }
          elseif ($Wait)
          {
              Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Uploading the last SupportAssistCollection for $($iDRACSession.ComputerName)"
          }
          else
          {
              return $job
          }
      }
      else
      {
          Throw "Job creation failed with an error: $($Job.Message)"
      }
  }
}

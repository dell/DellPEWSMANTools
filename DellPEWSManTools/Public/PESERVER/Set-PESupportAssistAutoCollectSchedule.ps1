<#
Set-PESupportAssistAutoCollectSchedule.ps1 - Register SupportAssist.

_author_ = Kristian Lamb <Kristian.Lamb@Dell.com> _version_ = 1.0

Copyright (c) 2019, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Set-PESupportAssistAutoCollectSchedule
{
  [CmdletBinding(DefaultParameterSetName='General')]
  Param
  (
      [Parameter(Mandatory,
                 ParameterSetName='Monthly')]
      [Parameter(Mandatory,
                 ParameterSetName='Weekly')]
      [Alias("s")]
      [ValidateNotNullOrEmpty()]
      $iDRACSession,

      [Parameter(Mandatory,
                 ParameterSetName='Monthly')]
      [Parameter(Mandatory,
                 ParameterSetName='Weekly')]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('WEEKLY','MONTHLY','QUARTERLY')]
      [String]$Recurrence,

      [Parameter(Mandatory,
                 ParameterSetName='Monthly')]
      [Parameter(Mandatory,
                 ParameterSetName='Weekly')]
      [ValidateNotNullOrEmpty()]
      [ValidatePattern('^[0-2][0-9]:[0-5][0-9]\s[AP][M]$')]
      [String]$Time,

      [Parameter(ParameterSetName='Monthly')]
      [ValidateNotNullOrEmpty()]
      [ValidatePattern("^[1-9][1-8]$|^[1-9L]$")]
      [String]$DayOfMonth,

      [Parameter(ParameterSetName='Weekly')]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('1','2','3','4','L')]
      [String]$WeekOfMonth,

      [Parameter(ParameterSetName='Weekly')]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('MON','TUE','WED','THU','FRI','SAT','SUN')]
      [String]$DayOfWeek
  )

  Begin
  {
      $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
      $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

      $Parameters = @{
          Time = $Time
          Recurrence = [SupportAssistRecurrence]$Recurrence -as [int]
      }
      if ($DayOfMonth)
      {
          $Parameters.Add('DayOfMonth', $DayOfMonth)
      }
      if ($WeekOfMonth)
      {
          $Parameters.Add('WeekOfMonth', $WeekOfMonth)
      }
      if ($DayOfWeek)
      {
          $Parameters.Add('DayOfWeek', $DayOfWeek)
      }
  }

  Process
  {
      $cmdresponse = Invoke-CimMethod -InputObject $instance -MethodName SupportAssistSetAutoCollectSchedule -CimSession $iDRACSession -Arguments $Parameters
      return $cmdresponse
  }
}

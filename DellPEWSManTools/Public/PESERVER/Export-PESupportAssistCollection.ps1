<#
Get-PESupportAssistCollection.ps1 - Trigger a SupportAssist collection and send to network share or Dell.

_author_ = Kristian Lamb <Kristian.Lamb@Dell.com> _version_ = 1.0

Copyright (c) 2019, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Export-PESupportAssistCollection
{
  [CmdletBinding(DefaultParameterSetName='General')]
  Param
  (
      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [Alias("s")]
      [Parameter(Mandatory,
                 ParameterSetName='Passthru')]
      [Parameter(Mandatory,
                 ParameterSetName='Wait')]
      [Parameter(Mandatory,
                 ParameterSetName='Share')]
      [Parameter(Mandatory,
                 ParameterSetName='ShareWait')]
      [Parameter(Mandatory,
                 ParameterSetName='SharePassThru')]
      [ValidateNotNullOrEmpty()]
      $iDRACSession,

      [Parameter(Mandatory,
                 ParameterSetName='Share')]
      [Parameter(Mandatory,ParameterSetName='ShareWait')]
      [Parameter(Mandatory,ParameterSetName='SharePassThru')]
      [Hashtable]$ShareObject,

      [Parameter(ParameterSetName='General')]
      [Parameter(ParameterSetName='Passthru')]
      [Parameter(ParameterSetName='Wait')]
      [Parameter(ParameterSetName='Share')]
      [Parameter(ParameterSetName='ShareWait')]
      [Parameter(ParameterSetName='SharePassThru')]
      [ValidateSet('DEBUG','OSAPPDATA','HWDATA','TTYLOGS')]
      [String[]]$DataSelector = 'HWDATA',

      [Parameter(Mandatory,ParameterSetName='General')]
      [Parameter(Mandatory,ParameterSetName='Passthru')]
      [Parameter(Mandatory,ParameterSetName='Wait')]
      [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
      [String] $IPAddress,

      [Parameter(Mandatory,ParameterSetName='General')]
      [Parameter(Mandatory,ParameterSetName='Passthru')]
      [Parameter(Mandatory,ParameterSetName='Wait')]
      [String]$ShareName,

      [Parameter(ParameterSetName='General')]
      [Parameter(ParameterSetName='Passthru')]
      [Parameter(ParameterSetName='Wait')]
      [ValidateSet("NFS","CIFS")]
      [String]$ShareType = "CIFS",

      [Parameter(ParameterSetName='General')]
      [Parameter(ParameterSetName='Passthru')]
      [Parameter(ParameterSetName='Wait')]
      [PSCredential]$Credential,

      [Parameter(ParameterSetName='General')]
      [Parameter(ParameterSetName='Passthru')]
      [Parameter(ParameterSetName='Wait')]
      [Parameter(ParameterSetName='Share')]
      [Parameter(ParameterSetName='ShareWait')]
      [Parameter(ParameterSetName='SharePassThru')]
      [Switch]$FilterPII,

      [Parameter(ParameterSetName='General')]
      [Parameter(ParameterSetName='Passthru')]
      [Parameter(ParameterSetName='Wait')]
      [Parameter(ParameterSetName='Share')]
      [Parameter(ParameterSetName='ShareWait')]
      [Parameter(ParameterSetName='SharePassThru')]
      [Switch]$Transmit,

      [Parameter(ParameterSetName='SharePassThru')]
      [Parameter(ParameterSetName='Passthru')]
      [Switch]$Passthru,

      [Parameter(ParameterSetName='Wait')]
      [Parameter(ParameterSetName='ShareWait')]
      [Switch]$Wait
  )

  Begin
  {
      $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
      $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

      if ($DataSelector -notcontains 'HWDATA')
      {
          $DataSelector += 'HWDATA'
      }

      $DataSelectorArray = foreach ($selector in $DataSelector) { [SupportAssistSelector]$selector -as [int] }

      if ($ShareObject)
      {
          $Parameters = $ShareObject.Clone()
      }
      else
      {
          $Parameters = @{
              IPAddress = $IPAddress
              ShareName = $ShareName
              ShareType = ([ShareType]$ShareType -as [int])
          }

          if ($Credential)
          {
              $Parameters.Add('Username',$Credential.GetNetworkCredential().UserName)
              $Parameters.Add('Password',$Credential.GetNetworkCredential().Password)
              if ($Credential.GetNetworkCredential().Domain)
              {
                  $Parameters.Add('Workgroup',$Credential.GetNetworkCredential().Domain)
              }
          }
      }

      $Parameters.Add('DataSelectorArrayIn', $DataSelectorArray)

      if ($FilterPII)
      {
        $Parameters.Add('Filter', 1)
      }
      if ($Transmit)
      {
        $Parameters.Add('Transmit', 1)
      }
  }

  Process
  {

      $job = Invoke-CimMethod -InputObject $instance -MethodName SupportAssistCollection -CimSession $iDRACSession -Arguments $Parameters

      if ($job.ReturnValue -eq 4096)
      {
          if ($Passthru)
          {
              $job
          }
          elseif ($Wait)
          {
              Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Running SupportAssistCollection for $($iDRACSession.ComputerName)"
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

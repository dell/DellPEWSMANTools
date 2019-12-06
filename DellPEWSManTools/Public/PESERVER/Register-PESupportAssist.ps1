<#
Register-PESupportAssist.ps1 - Register SupportAssist.

_author_ = Kristian Lamb <Kristian.Lamb@Dell.com> _version_ = 1.0

Copyright (c) 2019, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Register-PESupportAssist
{
  [CmdletBinding(DefaultParameterSetName='General')]
  Param
  (
      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [Alias("s")]
      [ValidateNotNullOrEmpty()]
      $iDRACSession,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$PrimaryFirstName,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$PrimaryLastName,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$PrimaryPhoneNumber,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [mailaddress]$PrimaryEmail,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$CompanyName,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$Street1,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$State,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$City,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$Zip,

      [Parameter(Mandatory,
                 ParameterSetName='General')]
      [ValidateNotNullOrEmpty()]
      [String]$Country,

      [Parameter(ParameterSetName='General')]
      [String]$PrimaryAlternateNumber,

      [Parameter(ParameterSetName='General')]
      [String]$Street2,

      [Parameter(ParameterSetName='General')]
      [String]$SecondaryFirstName,

      [Parameter(ParameterSetName='General')]
      [String]$SecondaryLastName,

      [Parameter(ParameterSetName='General')]
      [String]$SecondaryPhoneNumber,

      [Parameter(ParameterSetName='General')]
      [String]$SecondaryAlternateNumber,

      [Parameter(ParameterSetName='General')]
      [mailaddress]$SecondaryEmail,

      [Parameter(ParameterSetName='General')]
      [String]$ProxyHostName,

      [Parameter(ParameterSetName='General')]
      [String]$ProxyUserName,

      [Parameter(ParameterSetName='General')]
      [int]$ProxyPort,

      [Parameter(ParameterSetName='General')]
      [String]$ProxyPassword,

      [Parameter(ParameterSetName='General')]
      [Switch]$Passthru,

      [Parameter(ParameterSetName='General')]
      [Switch]$Wait
  )

  Begin
  {
      $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
      $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
      $Parameters = @{
          PrimaryFirstName = $PrimaryFirstName
          PrimaryLastName = $PrimaryLastName
          PrimaryPhoneNumber  = $PrimaryPhoneNumber
          PrimaryEmail  = $PrimaryEmail.ToString()
          CompanyName = $CompanyName
          Street1 = $Street1
          State = $State
          City = $City
          Zip = $Zip
          Country = $Country
      }
      if ($PrimaryAlternateNumber)
      {
          $Parameters.Add('PrimaryAlternateNumber', $PrimaryAlternateNumber)
      }
      if ($Street2)
      {
          $Parameters.Add('Street2', $Street2)
      }
      if ($SecondaryFirstName)
      {
          $Parameters.Add('SecondaryFirstName', $SecondaryFirstName)
      }
      if ($SecondaryLastName)
      {
          $Parameters.Add('SecondaryLastName', $SecondaryLastName)
      }
      if ($SecondaryPhoneNumber )
      {
          $Parameters.Add('SecondaryPhoneNumber', $SecondaryPhoneNumber)
      }
      if ($SecondaryAlternateNumber)
      {
          $Parameters.Add('SecondaryAlternateNumber', $SecondaryAlternateNumber)
      }
      if ($SecondaryEmail)
      {
          $Parameters.Add('SecondaryEmail', $SecondaryEmail.ToString())
      }
      if ($ProxyHostName)
      {
          $Parameters.Add('ProxyHostName', $ProxyHostName)
      }
      if ($ProxyUserName)
      {
          $Parameters.Add('ProxyUserName', $ProxyUserName)
      }
      if ($ProxyPort)
      {
          $Parameters.Add('ProxyPort', $ProxyPort)
      }
      if ($ProxyPassword)
      {
          $Parameters.Add('ProxyPassword', $ProxyPassword)
      }
  }

  Process
  {

      $job = Invoke-CimMethod -InputObject $instance -MethodName SupportAssistRegister -CimSession $iDRACSession -Arguments $Parameters

      if ($job.ReturnValue -eq 4096)
      {
          if ($Passthru)
          {
              $job
          }
          elseif ($Wait)
          {
              Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $job.Job.EndpointReference.InstanceID -Activity "Register SupportAssist for $($iDRACSession.ComputerName)"
          }
          else
          {
              return $job
          }
      }
      elseif ($job.ReturnValue -eq 0)
      {
          return $job
      }
      else
      {
          Throw "Job creation failed with an error: $($Job.Message)"
      }
  }
}

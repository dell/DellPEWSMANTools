<#
.Synopsis
   Sets the Power State of a PowerEdge Server system
.DESCRIPTION
   This cmdlet can be used to set the Power State of a PowerEdge Server System.
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   
   Set-PEPowerState

   Without the -State parameter, this cmdlet will attempt to PowerOn the target system.
.EXAMPLE
   The following example creates an iDRAC session and specifies PowerOff state using -State parameter
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff
.EXAMPLE
   The following example creates an iDRAC session, specifies PowerCycle state using -State parameter, and uses -Force to avoid prompting
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff -Force
.EXAMPLE
   The following example creates an iDRAC session, specifies PowerCycle state using -State parameter, and uses -Force to avoid prompting.
   Using -Passthru returns the object from the method invocation. This include the ReturnValue property from the method execution.
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Set-PEPowerState -iDRACSession $iDRACSession -State PowerOff -Force -Passthru
.INPUTS
   iDRACSession - CIM session with an iDRAC
   State - Intended state of the target system - PowerOn, PowerOff, PowerCycle
   Force - Eliminates prompting to confirm the action
   Passthru - returns the object from the method invocation
#>
function Set-PEPowerState
{
    [CmdletBinding(
                SupportsShouldProcess=$true,
                ConfirmImpact="High",
                DefaultParameterSetName='General'
    )]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Parameter(Mandatory, 
                   ParameterSetName='Passthru')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet("PowerOn","PowerOff","PowerCycle")]
        [String] $State = 'PowerOn',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Force,
        
        [Parameter(ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin 
    {
        $properties=@{CreationClassName="DCIM_ComputerSystem";Name="srv:system";}
        $instance = New-CimInstance -ClassName DCIM_ComputerSystem -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        if ($Force) 
        {
            $ConfirmPreference = 'None'
        }
    }

    Process 
    {
        if ($pscmdlet.ShouldProcess($iDRACSession.ComputerName, $State))
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName RequestStateChange -CimSession $iDRACSession -Arguments @{'RequestedState'= [PowerState]$State -as [int]}
            if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
            {
                $job
            }
        }
        
    }
}
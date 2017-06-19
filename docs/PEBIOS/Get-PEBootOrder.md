# Get-PEBootOrder #
## Synopsis ##
   Gets the boot order set in a PowerEdge Server system.
## DESCRIPTION ##
   This cmdlet can be used to get the boot order a PowerEdge Server System.
   The boot sequence is displayed in the order of current assigned sequence.
## PARAMETER iDRACSession ##
    Specifies the CIM session object created for the PE Server System.
## EXAMPLE ##
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBootOrder -iDRACSession $iDRACSession
## INPUTS ##
   iDRACSession - CIM session with an iDRAC.
## OUTPUTS ##
   Boot Order obtained from DCIM_BootSourceSetting.
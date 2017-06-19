# Get-PEBIOSAttribute #
## Synopsis ##
   Gets the PE BIOS attributes for a PowerEdge Server system.
## DESCRIPTION ##
   This cmdlet can be used to get a list of all possible BIOS attributes from a PowerEdge Server System.
   This can be used to retrieve the BIOS attributes from a specific group of attributes or just a single attribute.
## PARAMETER iDRACSession ##
   Specifies the CIM session object created for the PE Server System. 
## EXAMPLE ##
   The following example gets all PE BIOS attributes from a system.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession
## EXAMPLE ##
   The following example gets all PE BIOS attributes from a system and within the Processor Settings group.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -GroupDisplayName 'Processor Settings'
## EXAMPLE ##
   The following example gets a PE BIOS attribute from a system and within the Processor Settings group.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -GroupDisplayName 'Processor Settings' -AttributeDisplayName 'Number of Cores per Processor'  
## EXAMPLE ##
   The following example gets a PE BIOS attribute from a system using the AttributeName parameter instead of AttributeDisplayName parameter.
   
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)
   Get-PEBIOSAttribute -iDRACSession $iDRACSession -AttributeName 'ProcCores'     
## INPUTS ##
   iDRACSession - CIM session with an iDRAC.
   AttributeName - Attribute name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
   AttributeDisplayName - Attribute display name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
   GroupDisplayName - Group display name from the BIOS attribute listing. The argument to this parameter is case-sensitive.
## OUTPUTS ##
   Boot attribute information from the DCIM_BIOSEnumeration class.
# New-PEDRACSession #
## Synopsis ##
   Creates a new CIM session for a Dell Remote Access Controller (DRAC)
## DESCRIPTION ##
   This function takes IPAddress and Credential as parameters and creates a new CIM Session for a DRAC. This function returns the iDRACSession.
## EXAMPLE ##
   The following example takes IP address strings as pipeline input and creates iDRACSessions and returns the session objects
   $iDRACSession = '10.10.10.120', '10.10.10.121', '10.10.10.122' | New-PEDRACSession -Credential (Get-Credential)
   Get-PESystemInformation -iDRACSession $iDRACSession
## EAMPLE ##
    The following example shows setting the timeout value for session creation to 120 seconds
    $Credential = Get-Credential
    New-PEDRACSession -IPAddress 10.10.10.121 -Credential $Credential -MaxTimeout 120
## INPUTS ##
   IPAddress - IP Address of the iDRAC
   Credential - Credentials to authenticate to iDRAC
   MaxTimeout - Sets the timeout value for creating the session. The default value is 60 seconds
## OUTPUTS ##
   Microsoft.Management.Infrastructure.CimSession
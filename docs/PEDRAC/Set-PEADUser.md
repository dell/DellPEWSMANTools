# Set-PEADUser #
## Synopsis ##
   Configure an iDRAC user identified by the User number
## DESCRIPTION ##
   The Set-PEDRACUser cmdlet can create a new iDRAC user or modify the existing User using the Usernumber.
   The user can be enabled or disabled. Also the user privileges can be set.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The privilege number needs to be given in order to set the privilege for the user. To know what privilege number needs to be set, use the Get-PEDRACPrivilege cmdlet.
   
   The cmdlet will Throw an error if the configuration fails.
   
## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## PARAMETER userNumber ##
User Number.

## PARAMETER credential ##
Credential (Username and Password).

## PARAMETER privilege ##
Privilege level (0-511).

## PARAMETER enable ##
Enable the user.

## PARAMETER disable ##
Disable the user.

## PARAMETER Wait ##
Waits for the job to complete.

## PARAMETER Passthru ##
Returns the Job object without waiting.

## EXAMPLE ##
PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 5 -enable
   This command will enable the user identified by iDRAC.Embedded.1#Users.5

## EXAMPLE ##
PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 5 -disable
   This command will disable the user identified by iDRAC.Embedded.1#Users.5

## EXAMPLE ##
 PS C:\Windows\System32> Set-PEDRACUser -session $iDRACSession -userNumber 3 -credential (Get-Credential) -privilege 511 -enable -wait
   This command will configure the user identified by iDRAC.Embedded.1#Users.3 with Username and Password as supplied in the get-credential prompt.
   This user is enabled and given full privileges. The cmdlet will wait for the job to complete.

## INPUTS ##
   iDRACSession, Configuration paremeters
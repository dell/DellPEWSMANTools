# Set-PEADRoleGroup #
## Synopsis ##
   Configures the Active Directory Role Group.
## DESCRIPTION ##
   The Set-PEADRoleGroup cmdlet creates the Active Directory Role Group or modifies an exisiting Active Directory Role Group.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The Role Group number needs to be given in order create or modify any or all of Group name, Domain name or Privilege.
   To know what privilege number needs to be set, use the Get-PEDRACPrivilege cmdlet.
   The cmdlet will Throw an error if the configuration fails.

## EXAMPLE ##
PS C:\Windows\system32> Set-PEADRoleGroup -session $iDRACSession -roleGroupNumber 1 -groupName ABC -domainName DOMAIN -privilege 511
True

   This command will configure the Active Directory Role Group with Group name ABC, Domain name DOMAIN and privilege 511

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## PARAMETER roleGroupNumber ##
Role Group Number.

## PARAMETER groupName ##
Group Name.

## PARAMETER domainName ##
Domain Name.

## PARAMETER privilege ##
Privilege level (0-511).

## PARAMETER Wait ##
Waits for the job to complete.

## PARAMETER Passthru ##
Returns the Job object without waiting.

## INPUTS ##
   iDRACSession, configuration parameters
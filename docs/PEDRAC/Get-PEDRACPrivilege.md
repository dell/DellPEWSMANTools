# Get-PEDRACPrivilege #
## Synopsis ##
   This cmdlets gets the DRAC privilge value from specified privilige string(s)
## DESCRIPTION ##
   This cmdlets gets the DRAC privilge value from specified privilige string(s)
## EXAMPLE ##
    The following example gets the special privilege value for the Operator privilege
    Get-PEDRACPrivilge -SpecialPrivilege Operator
## EXAMPLE ##
   The following example gets the grouped privilege value from a set of privilege strings
   
   Get-PEDRACPrivilege -GroupedPrivilege Login,Configure,SystemControl,AccessVirtualMedia
## INPUTS ##
    GroupedPrivilege - Specifies an array of string values from the set 'Login','Configure','ConfigureUser','Logs','SystemControl','AccessVirtualConsole','AccessVirtualMedia','SystemOperation','Debug'
    SpecialPrivilege - Specifies a single string value from the set 'Admin','ReadOnly','Operator'
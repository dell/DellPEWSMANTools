# Get-PEADGroupInfo #
## Synopsis ##
   Gets the list of all AD Groups
## DESCRIPTION ##
   The Get-PEADGroupInfo cmdlet lists out details about all the AD Groups for the iDRAC specified. The output is a dictionary of AD Groups.
   The cmdlet will Throw an error if it fails to retrieve the information.

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## EXAMPLE ##
   Get-PEADGroupInfo -session $iDRACSession
Name                           Value                                                                                                                                         
----                           -----                                                                                                                                         
ADGroup1                       {Domain, Name, Privilege}
ADGroup2                       {Domain, Name, Privilege}                                                                                                                     
ADGroup3                       {Domain, Name, Privilege}                                                                                                                     
ADGroup4                       {Domain, Name, Privilege}                                                                                                                     
ADGroup5                       {Domain, Name, Privilege}

   This command will show all the AD Groups and the values in a map which are Group Name, Domain and Privilege.
## EXAMPLE ##
     $adGroups = Get-PEADGroupInfo $iDRACSession

     $adGroups.ADGroup2

Name                           Value                                                                                                                                         
----                           -----                                                                                                                                         
Domain                                                                                                                                                                       
Name                                                                                                                                                                         
Privilege                      0                                     
        
   This command gets the hashmap in the variable $adGroups. $users.User2 lists the UserName, Enable and Privilege and its corresponding Values.
## EXAMPLE ##
     $adGroups = Get-PEADGroupInfo $iDRACSession

     $adGroups.ADGroup2.Privilege

     0                               

   This command gets the hashmap in the variable $adGroups. $adGroups.ADGroup2.Privilege outputs the Privilege for ADGroup2 which is 0.

## INPUTS ##
   iDRACSession
## OUTPUTS ##
   System.Object
   This command returns a Hashtable
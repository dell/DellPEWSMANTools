# Get-PEDRACUser #
## Synopsis ##
   Gets the list of all iDRAC users
## DESCRIPTION ##
   The Get-PEDRACUser cmdlet lists out all the iDRAC users for the session given. The output is a hashmap of users.
   The cmdlet will Throw an error if it fails to retrieve the information.

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## EXAMPLE ##
   Get-PEDRACUser -session $iDRACSession
Name                           Value                                                                                             
----                           -----                                                                                             
User11                         {UserName, Enable, Privilege}                                                                     
User9                          {UserName, Enable, Privilege}                                                                     
User10                         {UserName, Enable, Privilege}                                                                     
User13                         {UserName, Enable, Privilege}                                                                     
User3                          {UserName, Enable, Privilege}                                                                     
User8                          {UserName, Enable, Privilege}                                                                     
User12                         {UserName, Enable, Privilege}                                                                     
User16                         {UserName, Enable, Privilege}                                                                     
User15                         {UserName, Enable, Privilege}                                                                     
User1                          {UserName, Enable, Privilege}                                                                     
User5                          {UserName, Enable, Privilege}                                                                     
User2                          {UserName, Enable, Privilege}                                                                     
User6                          {UserName, Enable, Privilege}                                                                     
User7                          {UserName, Enable, Privilege}                                                                     
User4                          {UserName, Enable, Privilege}                                                                     
User14                         {UserName, Enable, Privilege}                                                                     


   This command will show all the Users and the values in a map which are UserName, Enable and Privilege.
## EXAMPLE ##
     $users = Get-PEDRACUser $iDRACSession

     $users.User2

Name                           Value                                                                                             
----                           -----                                                                                             
UserName                       root                                                                                              
Enable                         Enabled                                                                                           
Privilege                      511                                   
        

   This command gets the hashmap in the variable $users. $users.User2 lists the UserName, Enable and Privilege and its corresponding Values.
## EXAMPLE ##
     $users = Get-PEDRACUser $iDRACSession

     $users.User2.Privilege

    511                               

   This command gets the hashmap in the variable $users. $users.User2.Privilege lists the Privilege for User2 which is 511.

## INPUTS ##
   iDRACSession
## OUTPUTS ##
   System.Object
   This command returns a Hashtable
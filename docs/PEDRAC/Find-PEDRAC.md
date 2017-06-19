# Find-PEDRAC #
## Synopsis ##
   Discovers all iDRACs and return a hashmap contained the discovered iDRACs.
## DESCRIPTION ##
   The Find-PEDRAC cmdlet accepts a range of IP addresses and up to three Username,Password lists. The IP start range and end range is a mandatory parameter. Atlease one Username and password list is required for the cmdlet.
   The cmdlet returns a hashtables where, the IP address is the key and its value is another hashtable with the system product information as the key/value pairs. 

## PARAMETER ipStartRange ##
Starting IP of the range.

## PARAMETER ipEndRange ##
Ending IP of the range.

## PARAMETER credential ##
a PSCredential object, will prompt for credential if kept blank.

## PARAMETER deepDiscover ##
This parameter returns additional details for each discovered server, including Service Tag, Model, and Power State.

## EXAMPLE ##
PS C:\Windows\system32> $dracs = Find-PEDRAC -ipStartRange 192.168.0.1 -ipEndRange 192.168.0.10 -credential (Get-Credential) -deepDiscover
    
This command returns a hashmap containing all discovered IPs into $drac with IP address as key. The contents of the hashtable will depend on the -deepDiscover switch.

## INPUTS ##
   ipStartRange, ipEndRange, credential, deepDiscover(optional)
## OUTPUTS ##
   System.Object
   This command returns a Hashtable
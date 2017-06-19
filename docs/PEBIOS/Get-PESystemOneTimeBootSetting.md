# Get-PESystemOneTimeBootSetting #
## SYNOPSIS ##
This cmdlet gets the One Time boot setting from the system

## DESCRIPTION ##
The one time boot setting defines what has been configured as the next (one time) boot device. 
This cmdlet returns information about the one time boot setting.

## PARAMETER iDRACSession ##
Specifies the CIM session object created for the PE Server System. 

## EXAMPLE ##
An example

## INPUTS ##
iDRACSession - CIM session with an iDRAC.

## OUTPUTS ##
Returns a custom object with OneTimeBootMode and OneTimeBootModeDev as the keys.
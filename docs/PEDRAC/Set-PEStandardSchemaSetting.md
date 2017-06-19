# Set-PEStandardSchemaSetting #
## Synopsis ##
   Configures the Standard Schema settings.
## DESCRIPTION ##
   The Set-PEStandardSchemaSetting cmdlet configures the Standard Schema settings for Active Directory enablement.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cmdlet can configure either or all Global Catalog Server Addresses.
   The cmdlet will Throw an error if it fails to set the values.

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## PARAMETER globalCatalogServerAddress1 ##
Gloabl Catalog Server IP Address 1.

## PARAMETER globalCatalogServerAddress2 ##
Gloabl Catalog Server IP Address 2.

## PARAMETER globalCatalogServerAddress3 ##
Gloabl Catalog Server IP Address 3.

## PARAMETER Wait ##
Waits for the job to complete.

## PARAMETER Passthru ##
Returns the Job object without waiting.

## EXAMPLE ##
   Set-Set-PEStandardSchemaSetting -session $iDRACSession -globalCatalogServerAddress1 $address1 -globalCatalogServerAddress2 $address2 -globalCatalogServerAddress3 $address3

   This command will configure the standard schema for the three addresses specified.

## INPUTS ##
   iDRACSession, configuration parameters
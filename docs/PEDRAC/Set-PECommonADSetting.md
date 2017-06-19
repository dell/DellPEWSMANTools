# Set-PECommonADSetting #
## Synopsis ##
   Configures the common Active Directory settings.
## DESCRIPTION ##
   The Set-PECommonADSetting cmdlet configures the Active Directory .
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cmdlet can configure the user domain , domain controller server addresses.
   The cmdlet can either enable or disable the certificate validation.
   The cmdlet can either enable or disable the Active directory.
   The cmdlet will Throw an error if the configuration fails.

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## PARAMETER userDomainName ##
User Domain Name.

## PARAMETER domainControllerServerAddress1 ##
Domain Controller Server Ip Address 1.

## PARAMETER domainControllerServerAddress2 ##
Domain Controller Server Ip Address 2.

## PARAMETER domainControllerServerAddress3 ##
Domain Controller Server Ip Address 3.

## PARAMETER enableCertificateValidation ##
Enable Certificate Validation.

## PARAMETER disableCertificateValidation ##
Disable Certificate Validation.

## PARAMETER enableAD ##
Enable Active Directory.

## PARAMETER disableAD ##
Disable Active Directory.

## PARAMETER Wait ##
Waits for the job to complete.

## PARAMETER Passthru ##
Returns the Job object without waiting.

## EXAMPLE ##
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -enableAD

This will enable Active Directory

## EXAMPLE ##
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -disableAD

This will disable Active Directory

## EXAMPLE ##
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -enableCertificateValidation -enableAD

This will enable Active Directory as well as enable Certificate Validation

## EXAMPLE ##
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -userDomainName <domainName>

This will set the user domain name to the value specified

## EXAMPLE ##
PS C:\Dell_PSCmdlets\Export-TechSupportReport> Set-PECommonADSetting -iDRACSession $session -userDomainName <domainName> -domainControllerServerAddress1 <address1> -enableCertificateValidation -enableAD

This will set the user domain name and domain Controller Server Address 1 to the values specified, enable Active Directory and Certificate Validation

## INPUTS ##
   iDRACSession, configuration parameters
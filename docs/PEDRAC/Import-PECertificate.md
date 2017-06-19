# Import-PECertificate #
## Synopsis ##
   Imports a Certificate.
## DESCRIPTION ##
   The Import-Certificate cmdlet imports the certificate given by the certificatefilename.
   The cmdlet takes in a session variable which is created by using the New-PEDRACSession cmdlet.
   The cetificateFileName is the path to the Certificate file. A passphrase may or may not be required depending on the certificate.
   The cmdlet can import either the WebServer Certificate or AD Service Certificate or the Custom Signing Certificate.
   The cmdlet will Throw an error if the import fails.

## PARAMETER iDRACSession ##
The session object created by New-PEDRACSession.

## PARAMETER certificateFileName ##
The complete path to the certificate file.

## PARAMETER passphrase ##
Passphrase for the certificate file.

## PARAMETER webServerCertificate ##
Option to identify the certificate as webServerCertificate.

## PARAMETER ADServiceCertificate ##
Option to identify the certificate as ADServiceCertificate.

## PARAMETER customSigningCertificate ##
Option to identify the certificate as customSigningCertificate.

## PARAMETER Wait ##
Waits for the job to complete.

## PARAMETER Passthru ##
Returns the Job object without waiting.

## EXAMPLE ##
   Import-PECertificate -session $iDRACSession -certificateFileName $certfile -passphrase pass -customSigningCertificate 

   This command will import the Custom Signing Certificate for the specified iDRAC using the passphrase pass

## INPUTS ##
   iDRACSession, certificateFileName, passphrase, certificateType(as option)

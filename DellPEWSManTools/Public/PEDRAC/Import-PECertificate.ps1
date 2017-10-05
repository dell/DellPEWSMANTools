<#
Import-PECertificate.ps1 - Imports a certificate into PE DRAC.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function Import-PECertificate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([String])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        # Pass phrase
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("pass")] 
        [SecureString]
        $passphrase,

        # Certificate Filename
        [Parameter(Mandatory,ParameterSetName='General')]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("cert")] 
        [string]
        $certificateFileName,

        # Web Server Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("wsc")] 
        [switch]
        $webServerCertificate,

        # AD Service Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("asc")] 
        [switch]
        $ADServiceCertificate,

        # Custom Signing Certificate
        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [Alias("csc")] 
        [switch]
        $customSigningCertificate,

        # Wait for job completion
        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        # Privilege
        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_iDRACCardService";Name="DCIM:iDRACCardService";}
        $instance = New-CimInstance -ClassName DCIM_iDRACCardService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $params=@{}

        if ( !$webServerCertificate -and !$ADServiceCertificate -and !$customSigningCertificate ) 
        {
            Throw "ERROR: Missing certificate type"
        }

        if ( ($webServerCertificate -and $ADServiceCertificate) -or ($ADServiceCertificate -and $customSigningCertificate) -or ($webServerCertificate -and $customSigningCertificate) ) 
        {
            Throw "ERROR: Cannot process multiple certificate types"
        }

    
        if ( $certificateFileName ) 
        {
            $data = Get-Content -Path $certificateFileName -Encoding String -Raw
            $certificate = [System.Convert]::ToBase64String( [System.Text.Encoding]::UTF8.GetBytes($data))

            if ( $certificate.Length -eq 0 ) 
            {
                Throw "ERROR: No certificate found in file specified"
            }
        }

        $params=@{}

        if ($certificate) 
        {
            $params.SSLCertificateFile = $certificate
        }

        if ($passphrase) 
        {
            # First create the credential out of the secure string and then fetch the clear text value of passphrase
            $tempCred = New-Object -Typename PSCredential -ArgumentList 'temp',$passphrase
            $params.Passphrase = $tempCred.GetNetworkCredntial().Password
        }

        if ($webServerCertificate) 
        {
            $params.CertificateType = "1"
        }
        elseif ($ADServiceCertificate) 
        {
            $params.CertificateType = "2"
        } 
        else 
        {
            $params.CertificateType = "3"
        }
    }
    Process
    {

        Write-Verbose "Importing Certificate to $($iDRACsession.ComputerName)"
        $responseData = Invoke-CimMethod -InputObject $instance -MethodName ImportSSLCertificate -CimSession $iDRACsession -Arguments $params #2>&1
        if ($responseData.ReturnValue -eq 4096) 
        {
            if ($Passthru) 
            {
                $responseData
            } 
            elseif ($Wait) 
            {
                Wait-PEConfigurationJob -iDRACSession $iDRACsession -JobID $responseData.Job.EndpointReference.InstanceID -Activity "Configuring Standard Schema Settings for $($iDRACsession.ComputerName)"
                Write-Verbose "Imported Certificate to $($iDRACsession.ComputerName) successfully"
            }
        } 
        else 
        {
            Throw "Certificate Import to $($iDRACsession.ComputerName) failed with error: $($responseData.Message)"
        }
    }
}

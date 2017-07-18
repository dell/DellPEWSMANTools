Function Find-PEDRAC
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        #ipStartRange 
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias ("ips")]
        [String]
        $ipStartRange,

        # ipEndRange
        [Parameter(Mandatory, 
                   ParameterSetName='General')]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [Alias ("ipe")]
        [String]
        $ipEndRange,
        
        # Credential
        [Parameter(Mandatory=$true, 
                   ParameterSetName='General')]
        [Alias ("cred")]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $credential,

        # Details switch
        [Parameter(ParameterSetName='General')]
        [Alias ("all")]
        [switch]
        $deepDiscover
    )
    
    Begin
    {
        function Find-PEDRAC_
        {
            [CmdletBinding(DefaultParameterSetName='General', 
                          PositionalBinding=$false,
                          SupportsShouldProcess=$true)]
            [OutputType([System.Collections.Hashtable])]
            # Suppressing the vars assignment rule because of the below bugs in the PSScriptAnalyzer v1.15.0     
            # https://github.com/PowerShell/PSScriptAnalyzer/issues/711
            # https://github.com/PowerShell/PSScriptAnalyzer/issues/699
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments',
                 '', Scope='Function')]
            Param
            (
                #ipStartRange 
                [Parameter(Mandatory, 
                           ParameterSetName='General')]
                [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
                [Alias ("ips")]
                [String]
                $ipStartRange,

                # ipEndRange
                [Parameter(Mandatory, 
                           ParameterSetName='General')]
                [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
                [Alias ("ipe")]
                [String]
                $ipEndRange,
        
                # Credential
                [Parameter(Mandatory=$true, 
                           ParameterSetName='General')]
                [Alias ("cred")]
                [PSCredential]
                [System.Management.Automation.Credential()]
                $credential,

                # Details switch
                [Parameter(ParameterSetName='General')]
                [Alias ("all")]
                [switch]
                $deepDiscover
            )

            Begin
            {
            }
            Process
            {
                if ($pscmdlet.ShouldProcess("iDRACs ", "Discover"))
                {
                    $start = $ipStartRange.split(".",4)[3]
                    $end = $ipEndRange.split(".",4)[3]
                    $firstthree = $ipStartRange.Remove($ipStartRange.LastIndexOf(".")) #xxx.xxx.xxx

                    $firstthreecheck = $ipEndRange.Remove($ipEndRange.LastIndexOf("."))

                    if ($firstthree -ne $firstthreecheck)
                    {
                        throw "IP range is not correct"
                        #return 0
                    }

                    $ipList = $start..$end | Foreach-Object -Process {$firstthree+"."+$_} #get ip range
                    Write-Verbose "Total number of IPs = $($ipList.Count)"

                    $cmd = {
                        param(
                            $ip,
                            [pscredential]
                            [System.Management.Automation.Credential()]
                            $credential,
                            $deepDiscover
                        )
                        $finalresultList = @{}
                        $credential | ForEach-Object -Process {
                            [xml]$result = ""
                            try
                            {
                                [xml]$result = winrm id -u:$_.GetNetworkCredential().UserName -p:$_.GetNetworkCredential().Password -r:https://$ip/wsman -SkipCNCheck -SkipCACheck -encoding:utf-8 -a:basic -format:pretty 2>&1
                
                                if (
                                    ($result.ChildNodes[0].ProductName -eq "iDRAC") -or 
                                    ($result.ChildNodes[0].ProductName -eq "Integrated Dell Remote Access Controller")
                                )
                                {
                                    try
                                    {
                                        $productName, $SystemType, $LCVersion, $iDRACVersion = $result.ChildNodes[0].ProductVersion.split(':')
                                        $SystemType = $SystemType.split('=')[1].Trim()
                                        $LCVersion = $LCVersion.split('=')[1].Trim()
                                        $iDRACVersion = $iDRACVersion.split('=')[1].Trim()
                                    }
                                    catch
                                    {
                                        $productName, $SystemType, $LCVersion, $iDRACVersion = $null, $null, $null, $null
                                    }
                                    $finalresultList[$ip] = @{
                                                                #UserName = $_.GetNetworkCredential().UserName;
                                                                #Password = $_.GetNetworkCredential().Password;
                                                                ProductVersion = $result.ChildNodes[0].ProductVersion;
                                                                Product = $result.ChildNodes[0].ProductName;
                                                                SystemType = $SystemType;
                                                                LCVersion = $LCVersion;
                                                                iDRACVersion = $iDRACVersion
                                                            }
                                    if ($deepDiscover)
                                    {
                                        try
                                        {
                                            $session = New-PEDRACSession -IPAddress $ip -Credential $_ -ErrorAction Stop
                                            $result2 = Get-PESystemInformation -iDRACSession $session -ErrorAction Stop  #2>&1
                                            $finalresultList[$ip].add('ServiceTag',$result2.ServiceTag)
                                            $finalresultList[$ip].add('Model',$result2.Model)
                                            $finalresultList[$ip].add('PowerState',$result2.PowerState)
                                        }
                                        catch
                                        {
                                            Write-Error "$_"
                                        }
                                    }
                                    $finalresultList
                                    break
                                } 
                            }
                            catch 
                            {
                                Write-Error 
                            }
                        } 
                    }
                    $jobs=@() 
                    $ipList | ForEach-Object {
                        $running = @(Get-Job | Where-Object { $_.State -eq 'Running' })
                        if ($running.Count -ge 10) 
                        {
                            $running | Wait-Job -Any | Out-Null
                        }
                        Write-Verbose "Discovering ip $_"      
                        $jobs += Start-Job -ScriptBlock $cmd -ArgumentList $_, $credential, $deepDiscover
                    } 
                    Wait-Job -Job $jobs | Out-Null 
                    Receive-Job -Job $jobs 
                }
            }
        }
        if( $null -eq $Credential.GetNetworkCredential().UserName)
        {
            Throw "Username cannot be empty"
        }
        if( $null -eq $Credential.GetNetworkCredential().Password)
        {
            Throw "Password cannot be empty"
        }        
    }
    Process
    {
            if ($deepDiscover)
            {
                $idracs = Find-PEDRAC_ -ipStartRange $ipStartRange -ipEndRange $ipEndRange -credential $credential -deepDiscover
            }
            else
            {
                $idracs = Find-PEDRAC_ -ipStartRange $ipStartRange -ipEndRange $ipEndRange -credential $credential
            }
            if ($idracs.Count -le 1)
            {
                $idracs
            }
            else
            {
                $idracMap=@{}
                for ($i=0; $i -lt $idracs.Count; $i++)
                {
                    [string]$ip = $idracs[$i].keys[0]
                    $idracMap.Add($ip,$idracs[$i][$ip])
                }
                $idracMap
            }
    }
}

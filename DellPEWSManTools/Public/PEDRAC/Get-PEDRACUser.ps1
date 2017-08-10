function Get-PEDRACUser
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false)]
    [OutputType([System.Collections.HashTable])]
    Param
    (
        # iDRAC Session
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession
    )

    Begin
    {
    }
    Process
    {

        Write-Verbose "Retrieving iDRAC User Details for $($iDRACsession.ComputerName)"
        Try{
            $map = @{}
            $users = 1..16 | Foreach-Object -Process {"User"+$_} 
            foreach ($user in $users)
            {
                $map.$user = @{"Privilege"="";"Enable"="";"UserName"=""}
            }

            #$responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardString" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardString where InstanceID like "%#UserName"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"
            $responseData = Get-CimInstance -CimSession $iDRACsession -ClassName DCIM_iDRACCardString -Namespace "root/dcim" -Filter 'InstanceID like "%#UserName"' -Property InstanceID, CurrentValue -ErrorAction Stop
            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.UserName = $currValue
            }


            #$responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardInteger" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardInteger where InstanceID like "iDRAC.Embedded.1#Users%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"
            $responseData = Get-CimInstance -CimSession $iDRACsession -ClassName DCIM_iDRACCardInteger -Namespace "root/dcim" -Filter 'InstanceID like "iDRAC.Embedded.1#Users%"' -Property InstanceID, CurrentValue -ErrorAction Stop
            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.Privilege = $currValue
            }

            #$responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardEnumeration" -Namespace "root/dcim" -Query 'Select InstanceID, CurrentValue from DCIM_iDRACCardEnumeration where InstanceID like "iDRAC.Embedded.1#Users%" and InstanceID like "%#Enable"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL"
            $responseData = Get-CimInstance -CimSession $iDRACsession -ClassName DCIM_iDRACCardEnumeration -Namespace "root/dcim" -Filter 'InstanceID like "iDRAC.Embedded.1#Users%"' -Property InstanceID, CurrentValue -ErrorAction Stop
            foreach ($resp in $responseData)
            {
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $currValue = $resp.CurrentValue
                    $key = "User"+$number
                    $map.$key.Enable = $currValue
            }
            Write-Verbose "iDRAC User Details for $($iDRACsession.ComputerName) retrieved successfully"

            $map
        } 

        Catch 
        {
            Throw "iDRAC User Details for $($iDRACsession.ComputerName) could not be retrieved"
        }
    }
}

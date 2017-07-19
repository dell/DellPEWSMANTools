function Get-PEADGroupInfo
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
        
        Write-Verbose "Retrieving AD Group Information for $($iDRACsession.ComputerName)"
        $map = @{}
        $users = 1..5 | Foreach-Object -Process {"ADGroup"+$_} 
        foreach ($user in $users)
        {
            $map.$user = @{"Privilege"="";"Domain"="";"Name"=""}
        }

        try
        {
            #$responseData = Get-CimInstance -CimSession $iDRACsession -ResourceUri "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/DCIM_iDRACCardAttribute" -Namespace "root/dcim" -Query 'Select CurrentValue, InstanceID from DCIM_iDRACCardAttribute where  InstanceID like "%ADGroup.%"' -QueryDialect "http://schemas.microsoft.com/wbem/wsman/1/WQL" 2>&1
            $responseData = Get-CimInstance -CimSession $iDRACsession -ClassName DCIM_iDRACCardAttribute -Namespace "root/dcim" -Filter 'InstanceID like "%ADGroup.%"' -Property InstanceID, CurrentValue -ErrorAction Stop
            foreach ($resp in $responseData){
                    $number = $resp.InstanceID.Split("#")[1].Split(".")[1]
                    $entity = $resp.InstanceID.Split("#")[-1]
                    $currValue = $resp.CurrentValue
                    $key = "ADGroup"+$number
                    $map.$key.$entity = $currValue
                    }
            Write-Verbose "AD Group Information for $($iDRACsession.ComputerName) retrieved successfully"
            $map
        }
        catch
        {
            Throw "Could Not Retrieve AD Group Information for $($iDRACsession.ComputerName)"
        }
    }
}

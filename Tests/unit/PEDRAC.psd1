@{
    MockInfo = @(
        @{
            Name='Get-PEDRACAttribute'
            MockObject = @(
                @{
                    CommandName='Get-CIMInstance'
                    MockWith = {throw 'failure'}
                    ParameterFilter = {
                        ($CIMSession -ne $Null) -and
                        ($NameSpace -eq 'root\dcim') 
                    }
                };
                @{
                    CommandName='New-CIMSession'
                    MockWIth = {}
                }
            )
        };
        @{
            Name='Get-PEDRACInformation'
            MockObject = @(
                @{
                    CommandName='Get-CIMInstance'
                    MockWith = {throw 'failure'}
                    ParameterFilter = {
                        ($CIMSession -ne $Null) -and
                        ($NameSpace -eq 'root\dcim') 
                    }
                };
                @{
                    CommandName='New-CIMSession'
                    MockWIth = {}
                }
            )
        }
    )
}

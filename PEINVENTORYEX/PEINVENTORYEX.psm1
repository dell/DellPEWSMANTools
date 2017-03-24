. "${PSScriptRoot}\Private\support.ps1"

function Get-PEInventory
{
    [cmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable] $ParamHash,

        [Parameter()]
        [Switch] $Raw,

        [Parameter()]
        [String] $OutputPath
    )

    process {
        $objectArray = @()
        #Initializtion based on the managementData retrieved from InventoryBlueprint.json
        $outputVariableName = $managementData.Initialization.OutputObject
        New-Variable -Name $outputVariableName -Value $(Initiaize-InventoryObject -ParamHash $ParamHash)
        
        #Generate all inventory objects
        $objectsToGenerate = $managementData.Objects.psobject.Properties.name
        Foreach ($object in $objectsToGenerate)
        {
            $getCommand = $managementData.Objects.$object.Get.Command
        
            $parameterString = ''
            #Generate Param String
            foreach ($inputParam in $managementData.Objects.$object.Get.Input)
            {
                $parameterName = $inputParam.ParameterName
                $parameterValue = $inputParam.Value
                if ($parameterValue -eq '$true')
                {
                    $parameterString += "-$parameterName "
                }
                else
                {
                    $parameterString += "-$parameterName `$$parameterValue "
                }
            }
            $getCommandString = @($getCommand, $parameterString) -join ' '
            
            #Execute the command
            $getObject = &([scriptblock]::create($getCommandString))
            New-Variable -Name $object -Value $getObject                                  
        }

        
        #Generate summary based on selectorset and qualifiers
        #Get the root object name
        foreach ($component in $managementData.Formatter.psobject.Properties.Name)
        {
           if ([bool]$managementData.Formatter.$component.IsRoot)
           {
                $root = $component
                break
           }
        }

        #region System component objects
        #Create a custom object with root object
        $inventoryObject = [Ordered] @{}
        
        #Generate the root values based on selectorset
        $rootSelectorProperties = $managementData.Formatter.$root.SelectorSet.Properties -join ','
        $rootSelectorString = "Select-Object ${rootSelectorProperties}"
        $rootSelectorCommand = @("Get-Variable -Name $root -valueOnly", $rootSelectorString) -join ' | '

        #Check for Qualifier
        #TODO
        
        $rootValues = &([scriptblock]::Create($rootSelectorCommand))
        $rootHash = [Ordered]@{}
        foreach ($value in $rootValues.psobject.Properties.Name)
        {
            $rootHash.Add($value,$rootValues.$value)
        }
        $inventoryObject.Add($root, $rootHash)

        #Find all child objects where $root is the parent
        foreach ($component in $managementData.Formatter.psObject.Properties.Name)
        {
            $componentFormatter = $managementData.Formatter.$component
            if (([bool]$componentFormatter.IsChild) -and ($componentFormatter.Parent -eq $root))
            {
                #Get the component object
                $componentObject = Get-Variable -Name $component -ValueOnly
                
                #Generate child values
                $childSelectorProperties = $componentFormatter.SelectorSet.Properties -join ','

                #Check if need unique values only
                if ([bool]$componentFormatter.SelectorSet.Qualifiers.UniqueOnly)
                {
                    $childSelectorString = "Select-Object ${childSelectorProperties} -Unique"
                }
                else
                {
                    $childSelectorString = "Select-Object ${childSelectorProperties}"   
                }

                #Check if we needto preselect
                #if ([bool]$componentFormatter.SelectorSet.Qualifiers.Preselect)
                #{
                #    $componentObjectpreselectCommand = @('$componentObject', $childSelectorString) -join ' | '
                #    $componentObject = &([scriptblock]::Create($componentObjectpreselectCommand)) 
                #}

                #Check if aggregation is needed; This will add a member
                if ([bool]$componentFormatter.SelectorSet.Qualifiers.Aggregate)
                {
                    if ($componentFormatter.SelectorSet.Qualifiers.Aggregate.By -eq 'InstanceCount')
                    {
                        $instanceCount = $componentObject.Count
                        $propertyName = $componentFormatter.SelectorSet.Qualifiers.Aggregate.PropertyName
                        $childSelectorString += " | Add-Member -NotePropertyName ${propertyName} -NotePropertyValue ${instanceCount} -force -Passthru" -join ' | '
                    }
                }
                
                if ([bool]$componentFormatter.IsArray)
                {
                    $componentDetailArray = @()
                    foreach ($instance in $componentObject)
                    {
                        #Create the command
                        $selectedObjectCommand = @('$instance',$childSelectorString) -join ' | ' 

                        #Run the command and get the object
                        $selectedObjectOutput = &([scriptblock]::Create($selectedObjectCommand))

                        $tempHash = [Ordered] @{}

                        foreach ($outputValue in $selectedObjectOutput.psobject.properties.Name)
                        {
                            $tempHash.Add($outputValue, $selectedObjectOutput.$outputValue)
                        }
                        
                        if ($componentFormatter.Related)
                        {
                            foreach ($relatedComponent in $componentFormatter.Related)
                            {
                                $relatedObjectName = $relatedComponent.RelatedObject
                                $relatedObject = Get-Variable -Name $relatedObjectName -ValueOnly
                                $relatedProperty = $relatedComponent.RelatedBy

                                #Get the selector set for this
                                $relatedSelectorProperties = $relatedComponent.SelectorSet.Properties -join ','

                                #Check if need unique values only
                                if ([bool]$relatedComponent.SelectorSet.Qualifiers.UniqueOnly)
                                {
                                    $relatedSelectorString = "Select-Object ${relatedSelectorProperties} -Unique"
                                }
                                else
                                {
                                    $relatedSelectorString = "Select-Object ${relatedSelectorProperties}"   
                                }

                                if ([bool]$relatedComponent.SelectorSet.Qualifiers.Aggregate)
                                {
                                    if ($relatedComponent.SelectorSet.Qualifiers.Aggregate.By -eq 'InstanceCount')
                                    {
                                        $relatedInstanceCount = $relatedObject.Count
                                        $relatedPropertyName = $relatedComponent.SelectorSet.Qualifiers.Aggregate.PropertyName
                                        $relatedSelectorString += " | Add-Member -NotePropertyName ${relatedPropertyName} -NotePropertyValue ${relatedInstanceCount} -force -Passthru" -join ' | '
                                    }
                                }

                                if ([bool]$relatedComponent.IsArray)
                                {
                                    $relatedComponentDetailArray = @()
                                    foreach ($relatedInstance in $relatedObject)
                                    {
                                        $relatedObjectCommand = @('$relatedInstance',$relatedSelectorString) -join ' | ' 
                                        $relatedObjectOutput = &([scriptblock]::Create($relatedObjectCommand))

                                        if ($relatedInstance.$relatedProperty.Contains($instance.$relatedProperty))
                                        {
                                            #Found the match and a real related instance
                                            $relatedInstancetempHash = [Ordered] @{}

                                            foreach ($relatedOutputValue in $relatedObjectOutput.psobject.properties.Name)
                                            {
                                                $relatedInstancetempHash.Add($relatedOutputValue, $relatedObjectOutput.$relatedOutputValue)
                                            }

                                            $relatedComponentDetailArray += $relatedInstancetempHash
                                        }
                                    }
                                    $tempHash.Add($relatedObjectName,$relatedComponentDetailArray)
                                }
                                else
                                {
                                    $relatedObjectCommand = @('$relatedObject',$relatedSelectorString) -join ' | ' 
                                    $relatedObjectOutput = &([scriptblock]::Create($relatedObjectCommand))

                                    $relatedInstancetempHash = [Ordered] @{}

                                    foreach ($relatedOutputValue in $relatedObjectOutput.psobject.properties.Name)
                                    {
                                        $relatedInstancetempHash.Add($relatedOutputValue, $relatedObjectOutput.$relatedOutputValue)
                                    }

                                    $tempHash.Add($relatedObjectName,$relatedInstancetempHash)
                                }
                            }
                        }

                        $componentDetailArray += $tempHash
                    }
                    $inventoryObject.$root.Add($component,$componentDetailArray)
                }
                else
                {
                    $selectedObjectCommand = @('$componentObject',$childSelectorString) -join ' | ' 
                    #Run the command and get the object
                    $selectedObjectOutput = &([scriptblock]::Create($selectedObjectCommand))
                    $tempHash = [Ordered] @{}

                    foreach ($outputValue in $selectedObjectOutput.psobject.properties.Name)
                    {
                        $tempHash.Add($outputValue, $selectedObjectOutput.$outputValue)
                    }
                    
                    $inventoryObject.$root.Add($component,$tempHash)
                }
            }
        }

        ##Get the Configuration object here
        $inventoryObject.Add('Configuration',@{})

        foreach ($configurationData in $managementData.Configuration.psobject.properties.name)
        {
            $configurationObject = @{}
            $getCommand = $managementData.Configuration.$configurationData.Get.Command
            $parameterString = ''
            #Generate Param String
            foreach ($inputParam in $managementData.Configuration.$configurationData.Get.Input)
            {
                $parameterName = $inputParam.ParameterName
                $parameterValue = $inputParam.Value
                if ($parameterValue -eq '$true')
                {
                    $parameterString += "-$parameterName "
                }
                else
                {
                    $parameterString += "-$parameterName `$$parameterValue "
                }
            }
            
            #Get the groups in this configuration data and the -GroupDisplyaName. Iterate over and get the values for each group
            foreach ($group in $managementData.Configuration.$configurationData.Groups.psobject.properties.Name)
            {
                $groupObject = @{}
                $paramStringWithGroup = $parameterString + " -GroupDisplayName `'$group`'"
                foreach ($attribute in $managementData.Configuration.$configurationData.Groups.$group)
                {
                    $paramStringWithAttribute = $paramStringWithGroup + " -AttributeDisplayName `'$attribute`'"
                    $getConfigCommandString = @($getCommand, $paramStringWithAttribute) -join ' '
                    $getConfigObject = &([scriptblock]::create($getConfigCommandString))
                    #New-Variable -Name $configurationData -Value $getConfigObject 
        
                    #apply the selector properties and get what we need.
                    $configFormatter = $managementData.Formatter
                    $configSelectorProperties = $configFormatter.$configurationData.SelectorSet.Properties -join ','
                    $configSelectorString = "Select-Object $configSelectorProperties"

                    $selectedConfigCommand = "`$getConfigObject | $configSelectorString"
                    $selectedConfigOutput = &([scriptblock]::Create($selectedConfigCommand))
                    $groupObject.Add($selectedConfigOutput.AttributeDisplayName, $selectedConfigOutput.CurrentValue)
                }
                $configurationObject.Add($group, $groupObject)
            }
            $inventoryObject.Configuration.Add($configurationData, $configurationObject)
        }

        if ($raw)
        {
            return $inventoryObject
        }
        elseif ($OutputPath)
        {
            $jsonString = $inventoryObject | ConvertTo-Json -Depth 100
            $jsonString | Out-File -FilePath $OutputPath -Force
        }
        else
        {
            $inventoryObject | ConvertTo-Json -Depth 100
        }
    }

}

function Compare-PEInventory
{
    [cmdletbinding()]
    param (
        [parameter(mandatory)]
        [String] $ReferenceSystem,

        [Parameter(mandatory)]
        [String[]] $DifferenceSystem,

        [Parameter(mandatory)]
        [pscredential] $Credential
    )

    process
    {
        #Get reference inventory JSON
        $referenceInventory = Get-PEInventory -ParamHash @{'username'=$Credential.UserName;'password'=$Credential.GetNetworkCredential().Password;'ipaddress'=$ReferenceSystem} -Verbose -Raw
        
        foreach ($system in $DifferenceSystem)
        {
            $differenceInventory = Get-PEInventory -ParamHash @{'username'=$Credential.UserName;'password'=$Credential.GetNetworkCredential().Password;'ipaddress'=$system} -Verbose -Raw
            $comparerObject = $managementData.Comparer
            foreach ($comparer in $comparerObject.psobject.Properties.name)
            {
                $mustMatchProperties = $comparerObject.$comparer.MustMatch
                foreach ($mandatoryProperty in $mustMatchProperties) 
                {
                    if ($differenceInventory.$comparer.$mandatoryProperty -ne $referenceInventory.$comparer.$mandatoryProperty)
                    {
                        #Take action based on the NoMatchAction
                        switch ($comparer.NoMatchAction)
                        {
                            "Halt" {
                                Write-Error -Message "Expected $system $mandatoryProperty to be $($referenceInventory.$comparer.$mandatoryProperty)"
                            }
                        }
                    }
                }

                #look at optional properties too
                $optionalProperties = $comparerObject.$comparer.Optional
                foreach ($optionalProperty in $optionalProperties)
                {
                    if ($differenceInventory.$comparer.$optionalProperty -ne $referenceInventory.$comparer.$optionalProperty)
                    {
                        #Take action based on the NoMatchAction
                        switch ($comparer.NoMatchAction)
                        {
                            "ReportError" {
                                $complianceHash = @{
                                    'Report'="Expected $system $optionalProperty to be $($referenceInventory.$comparer.$optionalProperty)"
                                    'ComplianceState' = $false
                                }
                                #Add a compliance object to the object being compared
                                $differenceInventory.$comparer.Add('Compliance',$complianceHash)
                            }
                        }
                    }
                }
            }
        }
    }
}

function Initiaize-InventoryObject 
{
    [cmdletBinding()]
    param (
        [hashtable] $ParamHash
    )

    process
    {
        $initializationCommand = $managementData.Initialization.Command
        $paramString = ''
        
        foreach ($parameter in $managementData.Initialization.Parameters)
        {
            $parameterName = $parameter.Name
            switch ($parameter.Type)
            {
                "PSCredential" {
                    $secpasswd = ConvertTo-SecureString $ParamHash.Password -AsPlainText -Force
                    $paramValue = New-Variable -Name $parameterName -Value (New-Object System.Management.Automation.PSCredential ($ParamHash.Username, $secpasswd)) -PassThru                    
                }
                "String" {
                    $paramValue = New-Variable -Name $parameterName -Value $($ParamHash.${parameterName}) -PassThru
                }
            }
            $paramString += "-${parameterName} `$$parameterName "
            
        }
        $initializationCommandString = @($initializationCommand, $paramString) -join ' '
        $initializationObject = &([scriptblock]::create($initializationCommandString))

        return $initializationObject
    }
}

Export-ModuleMember -Function *
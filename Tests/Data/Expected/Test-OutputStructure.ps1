Function Test-OutputStructure {
    <#
    .SYNOPSIS
    Test synopsis for Test-OutputStructure

    .DESCRIPTION
    Test description for Test-OutputStructure

    .OUTPUTS
    ([PSDocBuilder.CustomType]) - Parameter Sets: (All)
    A description for `PSDocBuilder.CustomType`.

    Contains:
    Name
        A description of the Name property of the output object.
    Value - [System.String]
        A description of the Value property of the output object. This should span across 120 characters so I can test
        out the wrapping functionality.
    Types
        A description for the Type property.
    #>
    [OutputType('PSDocBuilder.CustomType')]
    Param ()

    return [PSCustomObject]@{
        PSTypeName = 'PSDocBuilder.CustomType'
        Name = "Hello"
        Value = "World"
        Types = @("System.String", "System.Int32")
    }
}
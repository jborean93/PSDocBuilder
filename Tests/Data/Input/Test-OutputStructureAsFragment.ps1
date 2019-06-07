Function Test-OutputStructureAsFragment {
    <#
    ---
    synopsis: Test synopsis for Test-OutputStructureAsFragment
    description: Test description for Test-OutputStructureAsFragment
    outputs:
    - structure_fragment: structure_fragment
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
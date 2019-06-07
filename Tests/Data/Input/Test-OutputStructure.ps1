Function Test-OutputStructure {
    <#
    ---
    synopsis: Test synopsis for Test-OutputStructure
    description: Test description for Test-OutputStructure
    outputs:
    - description:
      - A description for `PSDocBuilder.CustomType`.
      structure:
      - name: Name
        description:
        - A description of the Name property of the output object.
      - name: Value
        description:
        - A description of the Value property of the output object. This should span across 120 characters so I can
          test out the wrapping functionality.
        type: System.String
      - name: Types
        description: A description for the Type property.
        when: Only when I choose to.
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
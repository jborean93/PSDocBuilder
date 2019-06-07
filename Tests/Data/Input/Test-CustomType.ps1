Function Test-CustomType {
    <#
    ---
    synopsis: Synopsis for Test-CustomType.
    description:
    - The description for Test-CustomType.
    parameters:
    - name: CustomType
      description:
      - A PSDocBuilder.TestClass object that is a dynamic type.
    examples:
    - name: Example 1
      description: Description for Example 1
      code: |
          $obj = New-Object -TypeName PSDocBuilder.TestClass
          $obj = Test-CustomType -CustomType $obj
    outputs:
    - description:
      - The custom type is returned back.
    #>
    [OutputType('PSDocBuilder.TestClass')]
    Param (
        [Parameter(Mandatory=$true)]
        [PSDocBuilder.TestClass]
        $CustomType
    )

    return
}
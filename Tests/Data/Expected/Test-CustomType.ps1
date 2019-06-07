Function Test-CustomType {
    <#
    .SYNOPSIS
    Synopsis for Test-CustomType.

    .DESCRIPTION
    The description for Test-CustomType.

    .PARAMETER CustomType
    [PSDocBuilder.TestClass]
    A PSDocBuilder.TestClass object that is a dynamic type.

    .EXAMPLE Example 1
    Description for Example 1

        $obj = New-Object -TypeName PSDocBuilder.TestClass
        $obj = Test-CustomType -CustomType $obj

    .OUTPUTS
    ([PSDocBuilder.TestClass]) - Parameter Sets: (All)
    The custom type is returned back.
    #>
    [OutputType('PSDocBuilder.TestClass')]
    Param (
        [Parameter(Mandatory=$true)]
        [PSDocBuilder.TestClass]
        $CustomType
    )

    return
}
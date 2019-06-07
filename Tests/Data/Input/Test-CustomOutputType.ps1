Function Test-CustomOutputType {
    <#
    ---
    synopsis: Synopsis for Test-CustomOutputType.
    description: Description for Test-CustomOutputType.
    outputs:
    - description: Custom output type.
    #>
    [OutputType('PSDocBuilder.InvalidClass')]
    Param ()
}
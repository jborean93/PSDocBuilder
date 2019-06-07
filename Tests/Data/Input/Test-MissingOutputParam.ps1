Function Test-MissingOutputParam {
    <#
    ---
    synopsis: Test synopsis.
    description:
    - Test description.
    parameters:
    - name: Parameter
      description: Test parameter description.
    #>
    [OutputType('System.String')]
    Param ($Parameter)
}
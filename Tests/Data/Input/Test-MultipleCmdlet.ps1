# Tests that the parser doesn't actually run the cmdlet.
Get-ChildItem -Path HKLM:\SOFTWARE

Function Test-MultipleCmdlet1 {
    <#
    ---
    synopsis: Synopsis for Test-MultipleCmdlet1.
    description:
    - The description for Test-MultipleCmdlet1.
    parameters:
    - name: Parameter
      description:
      - The description for Test-MultipleCmdlet1 -Parameter.
    examples:
    - name: Example 1
      description:
      - The description for `Test-MultipleCmdlet1` example 1.
      code: Test-MultipleCmdlet1 -Parameter 'abc'
    #>
    Param (
        [System.String]$Parameter
    )
}

Function Test-MultipleCmdlet2 {
    <#
    ---
    synopsis: Synopsis for Test-MultipleCmdlet2.
    description:
    - The description for Test-MultipleCmdlet2.
    parameters:
    - name: Parameter
      description:
      - The description for Test-MultipleCmdlet2 -Parameter.
    examples:
    - name: Example 1
      description:
      - The description for `Test-MultipleCmdlet2` example 1.
      code: Test-MultipleCmdlet2 -Parameter 'abc'
    #>
    Param (
        [System.String]$Parameter
    )
}
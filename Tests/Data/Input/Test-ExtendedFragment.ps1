Function Test-ExtendedFragment {
    <#
    ---
    synopsis: Test synopsis for a function with an extended fragment.
    description:
    - Some description for an advanced function with an extended fragment. This sentance should continue on and
      eventually wrap at around 120 characters long. The sentance should not be in a separate paragraph. Also add a
      link to a cmdlet with C(Cmdlet-Name).
    - Should be in a new paragraph.
    examples:
    - name: Test-ExtendedFragment Example 1
      description:
      - The first example of Test-ExtendedFragment 1. This sentance adds some filler to make sure that it tests the 120
        character limit for a PS doc.
      - Another entry for example 1 that tests out a new paragraph in the description.
      code: |-
        $res = Test-ExtendedFragment -Parameter1 "Some really long string value to test out link length." -Parameter3 1 -Choice "Choice 1" -SwithParam
        $output = "Hi: $($res)"

        Write-Output $output
    - name: Test-ExtendedFragment Example 2 scenario
      description: A simple description for the 2nd example of Test-ExtendedFragment.
      code: |-
        [PSCustomObject]@{Parameter2 = "abc"} | Test-ExtendedFragment -Parameter4 123 -Default "different value"
    parameters:
    - name: Default
      description:
      - Should show the default value in the markdown doc.
    - name: DefaultArray
      description:
      - Test to make sure we don't choke on an expression as a default value.
    - name: SwitchParam
      description:
      - The switch parameter.
    - name: Choice
      description:
      - Should show the valid choices in the markdown doc.
    inputs: []
    outputs:
    - description:
      - The first output should contain a String and Int32 output, it should also be for the `TestPS1` and `TestPS2`
        parameter sets.
      - Not sure what else to add here.
    - description: A simple description for the 2nd output parameter.
    - description:
      - Final description for an output of all parameter types.
    notes:
    - Some note 1, this should be in a single paragraph even though there are multiple sentances. Added some more
      filler to test out the line lengths.
    - Some note 2 in another paragraph.
    extended_doc_fragments:
    - test_fragment
    #>
    [OutputType([System.String], [System.Int32], ParameterSetName=("TestPS1", "TestPS2"))]
    [OutputType([System.String], ParameterSetName="TestPS3")]
    [OutputType([System.Int32])]
    Param (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName=("TestPS1", "TestPS2"), ValueFromPipeline)]
        [SupportsWildcards()]
        [Alias("MainAlias1", "MainAlias2")]
        [System.String]
        $Parameter1,

        [Parameter(Mandatory, Position=0, ParameterSetName="TestPS3", ValueFromPipeline=$true, ValueFromPipelineByPropertyName)]
        [Alias("Parameter2Alias")]
        [System.Int32]
        $Parameter2,

        [Parameter(Mandatory=$true, Position=1, ParameterSetName="TestPS1", ValueFromPipelineByPropertyName=$true)]
        [System.Int64]
        $Parameter3,

        [Parameter(Mandatory=$true, Position=1, ParameterSetName="TestPS2")]
        [System.Byte]
        $Parameter4,

        [Parameter(Mandatory=$true, Position=1, ParameterSetName="TestPS3")]
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Hashtable]
        $Parameter5,

        [System.String]
        $Default = "Default",

        [System.String[]]
        $DefaultArray = @(),

        [ValidateSet("Choice 1", "Choice 2")]
        $Choice,

        [Switch]
        $SwitchParam
    )
}
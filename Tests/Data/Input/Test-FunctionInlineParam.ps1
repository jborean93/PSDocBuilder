Function Test-FunctionInlineParam(
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
    ) {
    <#
    ---
    synopsis: Test synopsis for an advanced function with inline params.
    description:
    - Some description for an advanced inline param function. This sentance should continue on and eventually wrap at
      around 120 characters long. The sentance should not be in a separate paragraph. Also add a link to a cmdlet with
      C(Cmdlet-Name).
    - Should be in a new paragraph.
    examples:
    - name: Test-FunctionInlineParam Example 1
      description:
      - The first example of Test-FunctionInlineParam 1. This sentance adds some filler to make sure that it tests the
        120 character limit for a PS doc.
      - Another entry for example 1 that tests out a new paragraph in the description.
      code: |-
        $res = Test-FunctionInlineParam -Parameter1 "Some really long string value to test out link length." -Parameter3 1 -Choice "Choice 1" -SwithParam
        $output = "Hi: $($res)"

        Write-Output $output
    - name: Test-FunctionInlineParam Example 2 scenario
      description: A simple description for the 2nd example of Test-FunctionInlineParam.
      code: |-
        [PSCustomObject]@{Parameter2 = "abc"} | Test-FunctionInlineParam -Parameter4 123 -Default "different value"
    parameters:
    - name: Parameter1
      description: The description for Parameter1.
    - name: Parameter2
      description:
      - A long winded description for Parameter1 that spans across multiple lines. This should also fit inside one
        paragraph because it's in one yaml list entry.
      - A new paragraph should be set for this entry because it is in another yaml list entry.
    - name: Parameter3
      description:
      - The third parameter, nothing special.
    - name: Parameter4
      description:
      - The fourth parameter.
    - name: Parameter5
      description:
      - The fifth parameter.
    - name: Default
      description:
      - Should show the default value in the markdown doc.
    - name: DefaultArray
      description:
      - Test to make sure we don't choke on an expression as a default value.
    - name: Choice
      description:
      - Should show the valid choices in the markdown doc.
    - name: SwitchParam
      description:
      - The switch parameter.
    inputs:
    - name: Parameter1
      description:
      - A description for the first input parameter, this should only have the ByVal input flags.
    - name: Parameter2
      description:
      - A description for the 2nd parameter input. This should have both the `ByVal` and `ByPropertyName` flags set. I
        am also going to add a further sentance to this description.
    - name: Parameter3
      description: A description for the 3rd input parameter.
    - name: Parameter5
      description: Tests out multiple Parameter entries for a parameter.
    notes:
    - Some note 1, this should be in a single paragraph even though there are multiple sentances. Added some more
      filler to test out the line lengths.
    - Some note 2 in another paragraph.
    links:
    - link: https://www.google.com
    - link: https://www.google.com
      text: Google's Website
    - link: C(Another-Function)
    #>

    return
}
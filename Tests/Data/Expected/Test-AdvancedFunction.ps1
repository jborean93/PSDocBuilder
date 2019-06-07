Function Test-AdvancedFunction {
    <#
    .SYNOPSIS
    Test synopsis for an advanced function.

    .DESCRIPTION
    Some description for an advanced function. This sentance should continue on and eventually wrap at around 120
    characters long. The sentance should not be in a separate paragraph. Also add a link to a cmdlet with
    'Cmdlet-Name'.

    Should be in a new paragraph.

    .PARAMETER Parameter1
    [System.String]
    The description for Parameter1.

    .PARAMETER Parameter2
    [System.Int32]
    A long winded description for Parameter1 that spans across multiple lines. This should also fit inside one
    paragraph because it's in one yaml list entry.

    A new paragraph should be set for this entry because it is in another yaml list entry.

    .PARAMETER Parameter3
    [System.Int64]
    The third parameter, nothing special.

    .PARAMETER Parameter4
    [System.Byte]
    The fourth parameter.

    .PARAMETER Parameter5
    [System.Collections.Hashtable]
    The fifth parameter.

    .PARAMETER Default
    [System.String]
    Should show the default value in the markdown doc.

    .PARAMETER DefaultArray
    [System.String[]]
    Test to make sure we don't choke on an expression as a default value.

    .PARAMETER Choice
    [System.Object]
    Should show the valid choices in the markdown doc.

    .PARAMETER SwitchParam
    [System.Management.Automation.SwitchParameter]
    The switch parameter.

    .EXAMPLE Test-AdvancedFunction Example 1
    The first example of Test-AdvancedFunction 1. This sentance adds some filler to make sure that it tests the 120
    character limit for a PS doc.

    Another entry for example 1 that tests out a new paragraph in the description.

        $res = Test-AdvancedFunction -Parameter1 "Some really long string value to test out link length." -Parameter3 1 -Choice "Choice 1" -SwithParam
        $output = "Hi: $($res)"

        Write-Output $output

    .EXAMPLE Test-AdvancedFunction Example 2 scenario
    A simple description for the 2nd example of Test-AdvancedFunction.

        [PSCustomObject]@{Parameter2 = "abc"} | Test-AdvancedFunction -Parameter4 123 -Default "different value"

    .INPUTS
    [System.String]$Parameter1 - ByValue
    A description for the first input parameter, this should only have the ByVal input flags.

    .INPUTS
    [System.Int32]$Parameter2 - ByValue, ByPropertyName
    A description for the 2nd parameter input. This should have both the `ByVal` and `ByPropertyName` flags set. I am
    also going to add a further sentance to this description.

    .INPUTS
    [System.Int64]$Parameter3 - ByPropertyName
    A description for the 3rd input parameter.

    .INPUTS
    [System.Collections.Hashtable]$Parameter5 - ByPropertyName
    Tests out multiple Parameter entries for a parameter.

    .OUTPUTS
    ([System.String], [System.Int32]) - Parameter Sets: TestPS1, TestPS2
    The first output should contain a String and Int32 output, it should also be for the `TestPS1` and `TestPS2`
    parameter sets.

    Not sure what else to add here.

    .OUTPUTS
    ([System.String]) - Parameter Sets: TestPS3
    A simple description for the 2nd output parameter.

    .OUTPUTS
    ([System.Int32]) - Parameter Sets: (All)
    Final description for an output of all parameter types.

    .NOTES
    Some note 1, this should be in a single paragraph even though there are multiple sentances. Added some more filler
    to test out the line lengths.

    Some note 2 in another paragraph.

    .LINK
    https://www.google.com

    .LINK
    # Google's Website
    https://www.google.com

    .LINK
    'Another-Function'
    #>
    [CmdletBinding()]
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

    return
}
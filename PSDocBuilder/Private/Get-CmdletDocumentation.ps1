# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-CmdletDocumentation {
    <#
    ---
    synopsis: Parses a cmdlet and extracts the yaml documentation string.
    description:
    - Parses the cmdlet yaml documentation string and validates the structure before returning the Hashtable of that
      yaml representation.
    parameters:
    - name: Cmdlet
      description:
      - The cmdlet to parse. This cmdlet will report an error if it does not contain the proper yaml doc string.
    examples:
    - name: Get the cmdlet documentation.
      description:
      - Parses a cmdlet generated by C(Get-CmdletFromPath) and returns the hashtable representation of it's doc string.
      code: |
        $cmdlet = Get-CmdletFromPath -Path 'C:\PowerShell\test.ps1'
        $cmdlet_doc = Get-CmdletDocumentation -Cmdlet $cmdlet
    outputs:
    - description:
      - A hashtable that is the parsed yaml documentation string of the cmdlet.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Cmdlet
    )

    $cmdlet_string = $Cmdlet.ToString()
    $start_comment_idx = $cmdlet_string.IndexOf('<#', 0, [System.StringComparison]::OrdinalIgnoreCase)
    if ($start_comment_idx -eq -1) {
        throw "Failed to find any comment block in cmdlet '$($Cmdlet.Name)'."
    }

    $end_comment_idx = $cmdlet_string.IndexOf('#>', $start_comment_idx, [System.StringComparison]::OrdinalIgnoreCase)
    $cmdlet_comment = $cmdlet_string.Substring($start_comment_idx + 2, $end_comment_idx - $start_comment_idx - 2).Trim()

    try {
        $cmdlet_doc = ConvertFrom-Yaml -Yaml $cmdlet_comment
    } catch [YamlDotNet.Core.SyntaxErrorException] {
        $err = @{
            Message = "Failed to convert the first comment block in '$($Cmdlet.Name)' from yaml: $($_.Exception.InnerException.Message)"
            ErrorAction = 'Stop'
        }
        Write-Error @err
    }

    if ($cmdlet_doc -isnot [Hashtable]) {
        throw "Expecting cmdlet documentation to be a dictionary not '$($cmdlet_doc.GetType().Name)'"
    }

    Assert-DocumentationStructure -Schema $script:PSDocBuilderSchema -Documentation $cmdlet_doc -Name $Cmdlet.Name

    return $cmdlet_doc
}
# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-CmdletFromPath {
    <#
    ---
    synopsis: Extracts all the cmdlets in a script.
    description:
    - Parses a script and extracts the cmdlets in the script.
    parameters:
    - name: Path
      description:
      - The path to the script to parse.
    examples:
    - name: Parse cmdlets in a script
      description:
      - Parses all the cmdlets in the script `C:\PowerShell\test.ps1`.
      code: Get-CmdletFromPath -Path 'C:\PowerShell\test.ps1'
    outputs:
    - description:
      - The FunctionDefinitionAst for each cmdlet found in `Path`.
    #>
    [OutputType([System.Management.Automation.Language.FunctionDefinitionAst])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path
    )

    $script_data = Get-Content -LiteralPath $Path -Raw
    $script_block = [ScriptBlock]::Create($script_data)

    $function_predicate = {
        Param ([System.Management.Automation.Language.Ast]$Ast)
        $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }
    Write-Output -InputObject ($script_block.Ast.FindAll($function_predicate, $false))
}
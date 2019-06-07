# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Format-FunctionWithDoc {
    <#
    ---
    synopsis: Generate PowerShell and Markdown docs from cmdlet.
    description:
    - The `Format-FunctionWithDoc` cmdlet takes in an existing cmdlet and generates the PowerShell and Markdown
      documentation based on common schema set by `PSDocBuilder` and the actual cmdlet's metadata. The advantage of
      using a common documentation schema and build tools is that it guarantees the output docs to follow a common
      format and add extra functionality like sharing common doc snippets in multiple modules.
    parameters:
    - name: Path
      description:
      - Specifies the path to one ore more locations to a PowerShell script that contains one or more cmdlets. These
        cmdlets are then parsed and used to generate both PowerShell and Markdown documents from the existing metadata.
        Wildcard characters are permitted.
      - Use a dot (`.`) to specify the current location. Use the wildcard character (`*`) to specify all items in that
        location.
    - name: LiteralPath
      description:
      - Specifies the path to one or more locations to a PowerShell script that contains one or more cmdlet. These
        cmdlets are then parsed and used to generate both PowerShell and Markdown documents from the existing metadata.
      - The value for `LiteralPath` is used exactly as it is typed, use `Path` if you wish to use wildcard characters
        instead.
    - name: FragmentPath
      description:
      - The path to a directory that contains extra document fragments to use during the metadata parsing. This
        directory should contain one or more `*.yml` files which contains common keys and values to be merged into the
        cmdlet metadata. This is referenced by the `extended_doc_fragments` key in the cmdlet metadata.
    examples:
    - name: Generate a single module file from a module.
      description:
      - Uses the cmdlet to format an existing module that contains scripts in the `Private` and `Public` directory. The
        formatted functions are placed into single module file in the `Build` directory.
      code: |
        $public_script_path = ".\Module\Public\*.ps1"
        $private_script_path = ".\Module\Private\*.ps1"
        $doc_path = ".\Docs"
        $module_file = ".\Build\Module.psm1"

        Set-Content -Path $module -Value "# Copyright 2019 - Author Name"

        $public_cmdlets = [System.Collections.Generic.List`1[System.String]]@()
        Format-FunctionWithDoc -Path $public_script_path, $private_script_path | For-EachObject -Process {
            $parent = Split-Path -Path (Split-Path -Path $_.Source -Parent) -Leaf

            if ($parent -eq 'Public') {
                $public_cmdlets.Add($_.Name)
                Set-Content -Path (Join-Path -Path $doc_path -Child Path "$($_.Name).md") -Value $_.Markdown
            }

            Add-Content -Path $module -Value $_.Function
        }

        $module_footer = @"
        $public_functions = @(
            '$($public_cmdlets -join "',`r`n'")'
        )

        Export-ModuleMember -Functions $public_functions
        "@

        Add-Content -Path $module -Value $module_footer
    inputs:
    - name: Path
      description: You can pipe a string or property with the name of `Path` to this cmdlet.
    - name: LiteralPath
      description: You can pipe a property with the name of `LiteralPath` to this cmdlet.
    outputs:
    - description:
      - An object for each cmdlet inside the script(s) specified by `Path` or `LiteralPath`. The object has the name of
        the cmdlet as well as the formatted function with the PS and Markdown documentation.
      structure:
      - name: Name
        description: The name of the cmdlet.
        type: System.String
      - name: Source
        description: The full path to the source file the cmdlet was extracted from.
        type: System.String
      - name: Function
        description:
        - The full PowerShell function with the embedded PowerShell document. This value can then be used to populate
          the final build artifact the caller is creating.
        type: System.String
      - name: Markdown
        description:
        - The full Markdown document of the function. This value can be placed in a file in the output directory of the
          callers choice.
        type: System.String
    notes:
    - Each function found in the path will be dot sourced so the cmdlet can generate the Markdown syntax
      documentation. Any special types used by the cmdlet will need to be loaded before this will work.
    #>
    [OutputType('PSDocBuilder.FunctionDoc')]
    [CmdletBinding(DefaultParameterSetName='Path')]
    Param (
        [Parameter(Mandatory=$true, Position=0,
            ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,
            ParameterSetName='Path')]
        [SupportsWildcards()]
        [System.String[]]
        $Path,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,
            ParameterSetName='LiteralPath')]
        [System.String[]]
        $LiteralPath,

        [System.String]
        $FragmentPath
    )

    Begin {
        $nl = [System.Environment]::NewLine
        $doc_fragments = @{}
        if ($FragmentPath) {
            Write-Verbose -Message "Getting all .yml fragments in '$FragmentPath'."
            Get-ChildItem -LiteralPath $FragmentPath -File -Filter "*.yml" | ForEach-Object -Process {
                $doc_fragment = Get-Content -LiteralPath $_.FullName -Raw

                Write-Verbose -Message "Attempting to convert fragment '$($_.FullName)' to yaml."
                $doc_fragment = ConvertFrom-Yaml -Yaml $doc_fragment

                $assert_params = @{
                    Schema = $script:PSDocBuilderSchema
                    Documentation = $doc_fragment
                    Name = $_.BaseName
                    IsFragment = $true
                }
                Assert-DocumentationStructure @assert_params

                $doc_fragments."$($_.BaseName)" = $doc_fragment
            }
        }
    }

    Process {
        $path_params = @{}
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            Write-Verbose -Message "Using -Path value '$Path' for getting cmdlets."
            $path_params.Path = $Path
            $path_value = $Path
        } else {
            Write-Verbose -Message "Using -LiteralPath value '$LiteralPath' for getting cmdlets."
            $path_params.LiteralPath = $LiteralPath
            $path_value = $LiteralPath
        }

        try {
            if (-not (Test-Path @path_params -PathType Leaf)) {
                Write-Error -Message "Fail to find a file at '$path_value'" -ErrorAction Stop
            }

            Get-Item @path_params -Force | ForEach-Object -Process {
                Write-Verbose -Message "Getting cmdlets from '$($_.FullName)'."
                $cmdlets = @(Get-CmdletFromPath -Path $_.FullName)

                foreach ($cmdlet in $cmdlets) {
                    Write-Verbose -Message "Extracting cmdlet documentation for '$($cmdlet.Name)' in '$($_.FullName)'."
                    $cmdlet_doc = Get-CmdletDocumentation -Cmdlet $cmdlet

                    # Get the indexes for the existing function block inside the comments. We also calculate the indent
                    # they are at when we insert the new docs later on.
                    $cmdlet_string = $Cmdlet.ToString()
                    $ignore_case = [System.StringComparison]::OrdinalIgnoreCase
                    $start_comment_idx = $cmdlet_string.IndexOf('<#', 0, $ignore_case)
                    $end_comment_idx = $cmdlet_string.IndexOf('#>', $start_comment_idx, $ignore_case)
                    $newline_idx = $cmdlet_string.Substring(0, $start_comment_idx).LastIndexOf($nl)
                    $indent = $start_comment_idx - $newline_idx - 2

                    # Load the cmdlet so Get-Help works properly
                    .([ScriptBlock]::Create($cmdlet_string))

                    $cmdlet_meta_params = @{
                        Cmdlet = $cmdlet
                        Documentation = $cmdlet_doc
                        DocumentationFragments = $doc_fragments
                    }
                    $cmdlet_meta = Get-CmdletMetadata @cmdlet_meta_params

                    Write-Verbose -Message "Generating PowerShell documentation for '$($cmdlet.Name)' in '$($_.FullName)'."
                    $ps_doc = New-PowerShellDoc -Documentation $cmdlet_meta -Indent $indent

                    Write-Verbose -Message "Generating Markdown documentation for '$($cmdlet.Name)' in '$($_.FullName)'."
                    $md_doc = New-MarkdownDoc -Documentation $cmdlet_meta

                    # Add the doc string to the actual function
                    $function_string = (
                        "{0}{1}{2}{1}{3}{4}" -f (
                            $cmdlet_string.Substring(0, $start_comment_idx + 2),
                            $nl,
                            $ps_doc,
                            (" " * $indent),
                            $cmdlet_string.Substring($end_comment_idx, $cmdlet_string.Length - $end_comment_idx)
                        )
                    )

                    Write-Output -InputObject ([PSCustomObject]@{
                        PSTypeName = 'PSDocBuilder.FunctionDoc'
                        Name = $cmdlet.Name
                        Source = $_.FullName
                        Function = $function_string
                        Markdown = $md_doc
                    })
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
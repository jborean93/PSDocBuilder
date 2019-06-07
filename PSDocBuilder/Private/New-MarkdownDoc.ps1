# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function New-MarkdownDoc {
    <#
    ---
    synopsis: Generate a PowerShell markdown doc string for a cmdlet.
    description:
    - Generate a markdown documentation string based on the cmdlet metadata. This takes in the metadata as parsed by
      `PSDocHelper`.
    parameters:
    - name: Documentation
      description:
      - A hashtable that contains the cmdlet/function metadata which is translated into the markdown string. This
        hashtable is generated by `PSDocHelper`.
    examples:
    - name: Generate PowerShell markdown string.
      description:
      - Generate the PowerShell function markdown doc based on the path to the cmdlet.
      code: |-
        $cmdlet = Get-CmdletFromPath -Path C:\ps_cmdlet.ps1
        $cmdlet_doc = Get-CmdletDocumentation -Cmdlet $cmdlet
        $cmdlet_meta = Get-CmdletMetadata -Cmdlet $cmdlet -Documenation $cmdlet_doc
        $md_doc = New-MarkdownDoc -Documentation $cmdlet_meta
    outputs:
    - description:
      - The PowerShell doc string generated from the metadata.
    #>
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([System.String])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification='Not affecting system state, just outputting a string.'
    )]
    Param (
        [Parameter(Mandatory=$true)]
        [Hashtable]
        $Documentation
    )

    $nl = [System.Environment]::NewLine
    $syntax_lines = [System.Collections.Generic.List`1[System.String]]@()
    $cmdlet_syntax = (Get-Help -Name $Documentation.name).Synopsis
    foreach ($syntax in $cmdlet_syntax.Split($nl, [System.StringSplitOptions]::RemoveEmptyEntries)) {
        $syntax = $syntax | Format-IndentAndWrapping -Indent 4 -MaxLength 120
        $syntax_lines.Add($syntax.Substring(4))
    }

    $example_idx = 1
    $example_lines = [System.Collections.Generic.List`1[System.String]]@()
    foreach ($example in $Documentation.examples) {
        $description = $example.description | Format-IndentAndWrapping -MaxLength 120
        $code = $example.code.Split([System.Char[]]@("`r", "`n")) -join $nl  # Ensures newlines are based on the [System.Environment]::NewLine
        $example_lines.Add(
            "{0}### EXAMPLE {1}: {2}{0}{0}``````powershell{0}{3}{0}``````{0}{0}{4}" -f
                ($nl, $example_idx, $example.name, $code, $description)
        )
        $example_idx += 1
    }
    if ($example_lines.Count -eq 0) {
        $example_lines.Add('{0}None' -f $nl)
    }

    $parameter_lines = [System.Collections.Generic.List`1[System.String]]@()
    foreach ($parameter in $Documentation.parameters) {
        $description = $parameter.description | Format-IndentAndWrapping
        $aliases = "None"
        if ($parameter.aliases.Count -gt 0) {
            $aliases = $parameter.aliases -join ", "
        }

        # The metadata values don't match what we actually display.
        $parameter_sets = [Ordered]@{}
        foreach ($set in $parameter.parameter_sets.GetEnumerator()) {
            $pipeline_input = "False"
            if ($set.Value.pipeline_inputs.Count -gt 0) {
                $pipeline_input = "True ({0})" -f ($set.Value.pipeline_inputs -join ", ")
            }

            $set_info = [Ordered]@{
                Required = if ($set.Value.required) { "True" } else { "False" }
                Position = if ($null -eq $set.Value.position) { "Named" } else { $set.Value.position }
                "Accept pipeline input" = $pipeline_input
            }
            $parameter_sets.Add($set.Key, $set_info)
        }

        $extra_info = [Ordered]@{
            Type = $parameter.type
            Aliases = $aliases
            "Default value" = if ($null -eq $parameter.default) { "None" } else { $parameter.default }
            "Accept wildcard characters" = if ($parameter.accepts_wildcard) { "True" } else { "False" }
            "Parameter Sets" = $parameter_sets
        } | ConvertTo-Yaml

        $dynamic_str = ''
        if ($parameter.is_dynamic) {
            $dynamic_str = ' (Dynamic)'
        }

        $parameter_lines.Add(
            "{0}### -{1}{2}{0}{0}{3}{0}{0}``````{0}{4}``````" -f
                ($nl, $parameter.name, $dynamic_str, $description, $extra_info)
        )
    }
    if ($Documentation.cmdlet_binding) {
        $common_param = "{0}### CommonParameters{0}{0}This cmdlet supports the common parameters: -Debug, " -f $nl
        $common_param += "-ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, "
        $common_param += "-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more "
        $common_param += "information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)."
        $parameter_lines.Add($common_param)
    } elseif ($Documentation.parameters.Count -eq 0) {
        # Add None to signify no parameters are beng set.
        $parameter_lines.Add("{0}None" -f $nl)
    }

    $input_lines = [System.Collections.Generic.List`1[System.String]]@()
    foreach ($cmdlet_input in $Documentation.inputs) {
        $description = $cmdlet_input.description | Format-IndentAndWrapping
        $input_lines.Add(
            "{0}### [{1}] - {2} ({3}){0}{0}{4}" -f
                ($nl, $cmdlet_input.type, $cmdlet_input.name, ($cmdlet_input.pipeline_types -join ", "), $description)
        )
    }

    if ($input_lines.Count -eq 0) {
        $input_lines.Add("{0}None" -f $nl)
    }

    # Build the markdown string
    $markdown_string = @"
# $($Documentation.name)

## SYNOPSIS

$($Documentation.synopsis | Format-IndentAndWrapping)


## SYNTAX

``````
$($syntax_lines -join ($nl * 2))
``````


## DESCRIPTION

$($Documentation.description | Format-IndentAndWrapping)


## EXAMPLES
$($example_lines -join $nl)


## PARAMETERS
$($parameter_lines -join $nl)


## INPUTS
$($input_lines -join $nl)
"@

    if ($Documentation.outputs.Count -gt 0) {
        $markdown_string += "{0}{0}{0}## OUTPUTS" -f $nl
    }
    foreach ($output in $Documentation.outputs) {
        $description = $output.description | Format-IndentAndWrapping

        $struct_lines = [System.Collections.Generic.List`1[System.String]]@()
        foreach ($struct_entry in $output.structure) {
            $prop_description = $struct_entry.description | Format-IndentAndWrapping
            $struct_lines.Add(
                "|{0}|{1}|{2}|{3}|" -f ($struct_entry.name, $prop_description, $struct_entry.type, $struct_entry.when)
            )
        }

        $output_structure = ""
        if ($struct_lines.Count -gt 0) {
            $output_structure = (
                "{0}{0}| Property | Description | Type | Output When |{0}|----------|-------------|------|-------------|{0}{1}" -f ($nl, ($struct_lines -join $nl))
            )
        }

        $markdown_string += (
            "{0}{0}### Parameter Sets - {1}{0}{0}Output Types: ``[{2}]``{0}{0}{3}{4}" -f
                ($nl, ($output.parameter_sets -join ", "), ($output.types -join "], ["), $description, $output_structure)
        )
    }

    if ($Documentation.notes.Count -gt 0) {
        $notes = $Documentation.notes | Format-IndentAndWrapping
        $markdown_string += (
            "{0}{0}{0}## NOTES{0}{0}{1}" -f ($nl, $notes)
        )
    }

    if ($Documentation.links.Count -gt 0) {
        $markdown_string += "{0}{0}{0}## RELATED LINKS{0}" -f $nl
    }
    foreach ($link in $Documentation.links) {
        if ($link.link.StartsWith('C(')) {
            $link_text = $link.link
        } elseif ([System.String]::IsNullOrEmpty($link.text)) {
            $link_text = "[{0}]({0})" -f $link.link
        } else {
            $link_text = "[{0}]({1})" -f ($link.text, $link.link)
        }
        $markdown_string += (
            "{0}* {1}" -f ($nl, $link_text)
        )
    }

    # Replace instances of C(cmdlet name) for Markdown docs.
    $markdown_string = [System.Text.RegularExpressions.Regex]::Replace(
        $markdown_string,
        'C\(([\w-]*)\)',
        '[$1]($1.md)'
    )

    return $markdown_string
}
# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-CmdletMetadata {
    <#
    ---
    synopsis: Get the full metadata of a cmdlet.
    description:
    - Merges the cmdlet documentation structure with the actual metadata of the cmdlet into one object. The metadata
      can then be used to build the proper PowerShell and Markdown documentation.
    parameters:
    - name: Cmdlet
      description: The FunctionDefinitionAst of the cmdlet.
    - name: Documentation
      description: A hashtable that represents the cmdlet's documentation YAML string.
    - name: DocumentationFragments
      description: A hashtable that contains all the loaded documentation fragments.
    examples:
    - name: Get cmdlet metadata from file.
      description:
      - This will get the cmdlet metadata from the cmdlet at the path `C:\powershell\My-Function.ps1`.
      code: |
        $cmdlet = Get-CmdletFromPath -Path C:\powershell\My-Function.ps1
        $cmdlet_doc = Get-CmdletDocumentation -Cmdlet $cmdlet
        $cmdlet_meta = Get-CmdletMetadata -Cmdlet $cmdlet -Documentation $cmdlet_doc
    outputs:
    - description:
      - A hashtable that contains prepopulated and known keys that can be used by C(New-MarkdownDoc) and
        C(New-PowerShellDoc) to generate the doc entries.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $Cmdlet,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]
        $Documentation,

        [System.Collections.Hashtable]
        $DocumentationFragments = @{}
    )

    $Documentation.name = $Cmdlet.Name
    $Documentation.dynamic_params = ($null -ne $Cmdlet.Body.DynamicParamBlock -and $Cmdlet.Body.DynamicParamBlock.Statements.Count -gt 0)

    # Add an extended doc fragments to the documentation before verifying the rest of the inputs.
    foreach ($fragment in $Documentation.extended_doc_fragments) {
        if (-not $DocumentationFragments.ContainsKey($fragment)) {
            throw "Referenced documentation fragment '{0}' in '{1}' does not exist." -f ($fragment, $Cmdlet.Name)
        }
        Merge-Hashtable -InputObject $Documentation -Hashtable $DocumentationFragments.$fragment
    }

    # Verify the doc parameters match the actual cmdlet parameters.
    $param_block = $false
    $actual_params = [System.String[]]@()
    if ($null -ne $Cmdlet.Body.ParamBlock) {
        $param_block = $true
        $actual_params = [System.String[]]@($Cmdlet.Body.ParamBlock.Parameters | ForEach-Object -Process { $_.Name.VariablePath.UserPath })
    } elseif ($null -ne $Cmdlet.Parameters) {
        $actual_params = [System.String[]]@($Cmdlet.Parameters.Name.VariablePath.UserPath)
    }
    $documented_params = [System.String[]]@($Documentation.parameters | ForEach-Object -Process { $_.name })
    $missing_params = [System.String[]][System.Linq.Enumerable]::Except($actual_params, $documented_params)
    $extra_params = [System.String[]][System.Linq.Enumerable]::Except($documented_params, $actual_params)
    if ($missing_params.Length -gt 0) {
        throw "Parameter(s) '{0}' for {1} have not been documented." -f (($missing_params -join "', '"), $module.Name)
    }

    $dynamic_params = [System.Collections.Generic.List`1[System.Object]]@()
    if ($extra_params.Length -gt 0) {
        if ($Documentation.dynamic_params) {
            # Add the missing fields for each dynamic param doc entry.
            foreach ($doc_param in $extra_params) {
                $param_info = $Documentation.parameters | Where-Object { $_.name -eq $doc_param }
                if (-not $param_info.ContainsKey('accepts_wildcard')) {
                    $param_info.accepts_wildcard = $false
                }
                if (-not $param_info.ContainsKey('aliases')) {
                    $param_info.aliases = [System.Collections.Generic.List`1[System.String]]@()
                }
                if (-not $param_info.ContainsKey('default')) {
                    $param_info.default = $null
                }
                if (-not $param_info.ContainsKey('parameter_sets')) {
                    $param_info.parameter_sets = @{}
                }
                if (-not $param_info.ContainsKey('type')) {
                    $param_info.type = 'System.Object'
                }
                $param_info.is_dynamic = $true

                $dynamic_params.Add($param_info)
            }
        } else {
            throw "Parameter(s) '{0}' for {1} have been documented but not implemented." -f (($extra_params -join "', '"), $module.Name)
        }
    }

    # Store a state for whether common params are supported. They are if [CmdletBinding()] or [Parameter] is used.
    $common_params = $false
    if ($Cmdlet.Body.ParamBlock.Attributes | Where-Object { $_.TypeName.FullName -eq 'CmdletBinding' }) {
        $common_params = $true
    }

    # Add the cmdlet parameter info the documentation.
    $pipeline_by_value = [System.Collections.Generic.List`1[System.String]]@()
    $pipeline_by_prop = [System.Collections.Generic.List`1[System.String]]@()

    # Store parameters in the order defined by the Cmdlet not the doc block
    $parameters = [System.Collections.Generic.List`1[System.Object]]@()
    if ($param_block) {
        $cmdlet_params = $Cmdlet.Body.ParamBlock.Parameters
    } else {
        $cmdlet_params = $Cmdlet.Parameters
    }
    foreach ($param_info in $cmdlet_params) {
        $param = $Documentation.parameters | Where-Object { $_.name -eq $param_info.Name.VariablePath.UserPath }

        $default_value = $null
        if ($null -ne $param_info.DefaultValue) {
            $default_value = $param_info.DefaultValue.ToString()
            if (($default_value.StartsWith('"') -and $default_value.EndsWith('"')) -or
                ($default_value.StartsWith("'") -and $default_value.EndsWith("'"))) {

                $default_value = $default_value.Substring(1, $default_value.Length - 2)
            }
        }

        $param.accepts_wildcard = $false
        $param.aliases = [System.Collections.Generic.List`1[System.String]]@()
        $param.default = $default_value
        $param.parameter_sets = @{}
        $param.type = $param_info.StaticType.FullName

        foreach ($attr in $param_info.Attributes) {
            if ($attr.TypeName.FullName -eq 'Parameter') {
                $common_params = $true

                # First check if an explicit ParameterSetName was set
                $param_set_arg = $attr.NamedArguments | Where-Object { $_.ArgumentName -eq 'ParameterSetName' }
                if ($null -ne $param_set_arg) {
                    if ($param_set_arg.Argument -is [System.Management.Automation.Language.ParenExpressionAst]) {
                        $param_sets = [System.String[]]$param_set_arg.Argument.Pipeline.PipelineElements[0].Expression.Elements.Value
                        $current_param_set = $param_sets -join ", "
                    } else {
                        $current_param_set = $param_set_arg.Argument.Value
                    }
                } else {
                    $current_param_set = '(All)'
                }
                $param_set_values = [Ordered]@{
                    required = $false
                    position = $null
                    pipeline_inputs = [System.Collections.Generic.List`1[System.String]]@()
                }

                foreach ($param_arg in $attr.NamedArguments) {
                    $is_true = $param_arg.ExpressionOmitted -or $param_arg.Argument.VariablePath.UserPath -eq 'true'

                    if ($param_arg.ArgumentName -eq 'Mandatory' -and $is_true) {
                        $param_set_values.required = $true
                    } elseif ($param_arg.ArgumentName -eq 'Position') {
                        $param_set_values.position = $param_arg.Argument.Value
                    } elseif ($param_arg.ArgumentName -eq 'ValueFromPipeline' -and $is_true) {
                        $pipeline_by_value.Add($param.name)
                        $param_set_values.pipeline_inputs.Add('ByValue')
                    } elseif ($param_arg.ArgumentName -eq 'ValueFromPipelineByPropertyName' -and $is_true) {
                        $pipeline_by_prop.Add($param.name)
                        $param_set_values.pipeline_inputs.Add('ByPropertyName')
                    }
                }

                # Finally set the parameter set values to the metadata.
                $param.parameter_sets.$current_param_set = $param_set_values
            } elseif ($attr.TypeName.FullName -eq 'Alias') {
                $param.aliases.AddRange([System.String[]]$attr.PositionalArguments.Value)
            } elseif ($attr.TypeName.FullName -eq 'SupportsWildcards') {
                $param.accepts_wildcard = $true
            }
        }

        if ($param.parameter_sets.Count -eq 0) {
            # No [Parameter()] block was set for the parameter, add the default attributes for (All)
            $param.parameter_sets."(All)" = @{
                required = $false
                position = $null
                pipeline_inputs = [System.Collections.Generic.List`1[System.String]]@()
            }
        }

        $param.is_dynamic = $false
        $parameters.Add($param)
    }
    $parameters.AddRange($dynamic_params)
    $Documentation.parameters = $parameters

    # Add a flag that states the parameter supports the default CmdletBinding parameters
    $Documentation.cmdlet_binding = $common_params

    # Verify the doc inputs match the actual input parameters.
    $actual_pipeline_params = [System.String[]]@($pipeline_by_value + $pipeline_by_prop | Select-Object -Unique)
    $documented_input_params = [System.String[]]@($Documentation.inputs | ForEach-Object -Process { $_.name })
    $missing_params = [System.String[]][System.Linq.Enumerable]::Except($actual_pipeline_params, $documented_input_params)
    $extra_params = [System.String[]][System.Linq.Enumerable]::Except($documented_input_params, $actual_pipeline_params)
    if ($missing_params.Length -gt 0) {
        throw "Input parameter(s) '{0}' for {1} have not been documented." -f (($missing_params -join "', '"), $Cmdlet.Name)
    }
    if ($extra_params.Length -gt 0) {
        throw "Input parameter(s) '{0}' for {1} have been documented but not implemented." -f (($extra_params -join "', '"), $Cmdlet.Name)
    }

    # Add the extra input information.
    for ($i = 0; $i -lt $Documentation.inputs.Count; $i++) {
        $doc_input = $Documentation.inputs[$i]

        $param = $Documentation.parameters | Where-Object { $_.Name -eq $doc_input.name }
        $doc_input.type = $param.type
        $doc_input.pipeline_types = [System.Collections.Generic.List`1[System.String]]@()
        if ($doc_input.name -in $pipeline_by_value) {
            $doc_input.pipeline_types.Add('ByValue')
        }
        if ($doc_input.name -in $pipeline_by_prop) {
            $doc_input.pipeline_types.Add('ByPropertyName')
        }

        $Documentation.inputs[$i] = $doc_input
    }

    # Verify the doc outputs match the actual cmdlet output types.
    $actual_output_types = [System.Collections.Generic.List`1[System.Object]]@()
    foreach ($output_type in $Cmdlet.Body.ParamBlock.Attributes | Where-Object { $_.TypeName.FullName -eq 'OutputType' }) {
        $parameter_set_names = [System.Collections.Generic.List`1[System.String]]@()
        $param_set_arg = $output_type.NamedArguments | Where-Object { $_.ArgumentName -eq 'ParameterSetName' }
        if ($null -ne $param_set_arg) {
            if ($param_set_arg.Argument -is [System.Management.Automation.Language.ParenExpressionAst]) {
                $parameter_set_names.AddRange(
                    [System.String[]]$param_set_arg.Argument.Pipeline.PipelineElements[0].Expression.Elements.Value
                )
            } else {
                $parameter_set_names.Add($param_set_arg.Argument.Value)
            }
        }

        if ($parameter_set_names.Count -eq 0) {
            $parameter_set_names.Add('(All)')
        }

        $types = [System.Collections.Generic.List`1[System.String]]@()
        foreach ($type in $output_type.PositionalArguments) {
            if ($type -is [System.Management.Automation.Language.TypeExpressionAst]) {
                $types.Add($type.TypeName.FullName)
            } else {
                $type_as_type = $type.Value -as [Type]
                if ($null -ne $type_as_type) {
                    $types.Add($type_as_type.FullName)
                } else {
                    $types.Add($type.Value)
                }
            }
        }

        $actual_output_types.Add([PSCustomObject]@{
            types = $types
            parameter_sets = $parameter_set_names
        })
    }
    if ($actual_output_types.Count -ne $Documentation.outputs.Count) {
        throw ("Output type(s) count mismatch for {0}, expecting {1} documented outputs but got {2}." -f
            ($Cmdlet.Name, $actual_output_types.Count, $Documentation.outputs.Count))
    }

     # Add the extra outputs information.
    for ($i = 0; $i -lt $actual_output_types.Count; $i++) {
        # Expand the structure fragment
        $fragment_name = $Documentation.outputs[$i].structure_fragment
        if (-not [System.String]::IsNullOrEmpty($fragment_name)) {
            if (-not $DocumentationFragments.ContainsKey($fragment_name)) {
                throw "Referenced documentation fragment '{0}' in '{1}' does not exist." -f ($fragment_name, $Cmdlet.Name)
            }

            Merge-Hashtable -InputObject $Documentation.outputs[$i] -Hashtable $DocumentationFragments.$fragment_name.outputs[0]
        }

        $actual_output_type = $actual_output_types[$i]
        $Documentation.outputs[$i].types = $actual_output_type.types
        $Documentation.outputs[$i].parameter_sets = $actual_output_type.parameter_sets
    }

    return $Documentation
}
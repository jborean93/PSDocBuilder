# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$cmdlet_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$module_name = (Get-ChildItem -Path $PSScriptRoot\.. -Directory -Exclude @("Build", "Docs", "Tests")).Name
Import-Module -Name $PSScriptRoot\..\$module_name -Force

Describe "$cmdlet_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'Should format <File> function' -TestCases @(
            @{ File = 'Test-EmptyFunction' },
            @{ File = 'Test-AdvancedFunction' },
            @{ File = 'Test-FunctionInlineParam' },
            @{ File = 'Test-FunctionInlineNoCommon' },
            @{ File = 'Test-NoIndent' }
        ) {
            Param ([System.String]$File)

            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath "$($File).ps1") -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath "$($File).md") -Raw

            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', "$($File).ps1")

            $actual = Format-FunctionWithDoc -Path $function_path
            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be $File
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should work with relative paths' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-AdvancedFunction.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-AdvancedFunction.md') -Raw

            $function_path = [System.IO.Path]::Combine('.', 'Data', 'Input', 'Test-AdvancedFunction.ps1')

            Push-Location -Path $PSScriptRoot
            try {
                $actual = Format-FunctionWithDoc -Path $function_path
            } finally {
                Pop-Location
            }
            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-AdvancedFunction'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be ([System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-AdvancedFunction.ps1'))
        }

        It 'Should work with multiple param strings with <Name> param' -TestCases @(
            @{ Name = 'Path' },
            @{ Name = 'LiteralPath' }
        ) {
            Param ($Name)

            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')

            $expected_no_common_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.ps1') -Raw
            $expected_no_common_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.md') -Raw

            $expected_inline_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.ps1') -Raw
            $expected_inline_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.md') -Raw

            $input_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input')
            $test_path1 = Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineNoCommon.ps1'
            $test_path2 = Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineParam.ps1'

            $test_params = @{
                $Name = @($test_path1, $test_path2)
            }
            $actual = Format-FunctionWithDoc @test_params

            $actual.Length | Should -Be 2
            $actual[0].GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual[0].PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual[0].PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual[0].Name | Should -Be 'Test-FunctionInlineNoCommon'
            $actual[0].Function | Should -Be $expected_no_common_ps
            $actual[0].Markdown | Should -Be $expected_no_common_md
            $actual[0].Source | Should -Be $test_path1

            $actual[1].Name | Should -Be 'Test-FunctionInlineParam'
            $actual[1].Function | Should -Be $expected_inline_ps
            $actual[1].Markdown | Should -Be $expected_inline_md
            $actual[1].Source | Should -Be $test_path2
        }

        It 'Should work with pipeline by Val input' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')

            $expected_no_common_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.ps1') -Raw
            $expected_no_common_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.md') -Raw

            $expected_inline_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.ps1') -Raw
            $expected_inline_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.md') -Raw

            $input_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input')
            $actual = @(
                (Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineNoCommon.ps1'),
                (Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineParam.ps1')
             ) | Format-FunctionWithDoc

            $actual.Length | Should -Be 2
            $actual[0].GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual[0].PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual[0].PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual[0].Name | Should -Be 'Test-FunctionInlineNoCommon'
            $actual[0].Function | Should -Be $expected_no_common_ps
            $actual[0].Markdown | Should -Be $expected_no_common_md

            $actual[1].Name | Should -Be 'Test-FunctionInlineParam'
            $actual[1].Function | Should -Be $expected_inline_ps
            $actual[1].Markdown | Should -Be $expected_inline_md
        }

        It 'Should work with pipeline by PropName <Name> input' -TestCases @(
            @{ Name = 'Path' },
            @{ Name = 'LiteralPath' }
        ) {
            Param ($Name)

            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')

            $expected_no_common_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.ps1') -Raw
            $expected_no_common_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.md') -Raw

            $expected_inline_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.ps1') -Raw
            $expected_inline_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.md') -Raw

            $input_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input')
            $actual = @(
                [PSCustomObject]@{ $Name = (Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineNoCommon.ps1') },
                [PSCustomObject]@{ $Name = (Join-Path -Path $input_path -ChildPath 'Test-FunctionInlineParam.ps1') }
             ) | Format-FunctionWithDoc

            $actual.Length | Should -Be 2
            $actual[0].GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual[0].PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual[0].PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual[0].Name | Should -Be 'Test-FunctionInlineNoCommon'
            $actual[0].Function | Should -Be $expected_no_common_ps
            $actual[0].Markdown | Should -Be $expected_no_common_md

            $actual[1].Name | Should -Be 'Test-FunctionInlineParam'
            $actual[1].Function | Should -Be $expected_inline_ps
            $actual[1].Markdown | Should -Be $expected_inline_md
        }

        It 'Should work with glob like chars' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')

            $expected_no_common_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.ps1') -Raw
            $expected_no_common_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineNoCommon.md') -Raw

            $expected_inline_ps = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.ps1') -Raw
            $expected_inline_md = Get-Content -Path (Join-Path -Path $expected_path -ChildPath 'Test-FunctionInlineParam.md') -Raw


            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-FunctionInline*.ps1')
            $actual_param = Format-FunctionWithDoc -Path $test_path
            $actual_pipeline = $test_path | Format-FunctionWIthDoc

            foreach ($actual in @($actual_param, $actual_pipeline)) {
                $actual.Length | Should -Be 2
                $actual[0].GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
                $actual[0].PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
                ($actual[0].PSObject.Properties.Name | Sort-Object) | Should -Be @(
                    'Function',
                    'Markdown',
                    'Name',
                    'Source'
                )

                $actual[0].Name | Should -Be 'Test-FunctionInlineNoCommon'
                $actual[0].Function | Should -Be $expected_no_common_ps
                $actual[0].Markdown | Should -Be $expected_no_common_md

                $actual[1].Name | Should -Be 'Test-FunctionInlineParam'
                $actual[1].Function | Should -Be $expected_inline_ps
                $actual[1].Markdown | Should -Be $expected_inline_md
            }
        }

        It 'Should fail with glob like chars and -LiteralPath' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', '*.ps1')
            $expected = "Fail to find a file at '$test_path"
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should error when file not found' {
            $expected = "Fail to find a file at 'C:\fakepath'"
            { Format-FunctionWithDoc -Path 'C:\fakepath' } | Should -Throw $expected
        }

        It 'Should error when path is a directory' {
            $expected = "Fail to find a file at '$env:SystemRoot'"
            { Format-FunctionWithDoc -Path $env:SystemRoot } | Should -Throw $expected
        }

        It 'Should work with manually set dynamic params' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-DynamicParam.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-DynamicParam.md') -Raw

            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-DynamicParam.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-DynamicParam'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should work with fragments' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-ExtendedFragment.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-ExtendedFragment.md') -Raw

            $fragment_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Fragments')
            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-ExtendedFragment.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path -FragmentPath $fragment_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-ExtendedFragment'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should fail when no fragment path is set but fragments were encountered' {
            $expected = 'Referenced documentation fragment ''test_fragment'' in ''Test-ExtendedFragment'' does not exist.'
            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-ExtendedFragment.ps1')

            { Format-FunctionWithDoc -Path $function_path } | Should -Throw $expected
        }

        It 'Should load a cmdlet with a custom type' {
            Add-Type -WarningAction SilentlyContinue -TypeDefinition @'
using System;

namespace PSDocBuilder
{
    public class TestClass
    {
    }
}
'@
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-CustomType.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-CustomType.md') -Raw

            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-CustomType.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-CustomType'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should parse a cmdlet with an output type that is not loaded' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-CustomOutputType.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-CustomOutputType.md') -Raw

            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-CustomOutputType.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-CustomOutputType'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should parse multiple cmdlets in a script' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-MultipleCmdlet.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path

            $actual.Length | Should -Be 2
            foreach ($a in $actual) {
                $a.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
                $a.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
                ($a.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                    'Function',
                    'Markdown',
                    'Name',
                    'Source'
                )

                $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath "$($a.Name).ps1") -Raw
                $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath "$($a.Name).md") -Raw

                $a.Name -in @('Test-MultipleCmdlet1', 'Test-MultipleCmdlet2') | Should -Be $true
                $a.Function | Should -Be $expected_ps
                $a.Markdown | Should -Be $expected_md
                $a.Source | Should -Be $function_path
            }
        }

        It 'Should fail when using both -Path and -LiteralPath' {
            $expected = 'Parameter set cannot be resolved using the specified named parameters.'
            { Format-FunctionWithDoc -Path $env:SystemRoot -LiteralPath $env:SystemRoot } | Should -Throw $expected
        }

        It 'Should fail with missing parameter key' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-MissingDocParam.ps1')
            $expected = "Parameter(s) 'ExtraParam' for  have not been documented."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with extra documentation key' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-ExtraDocParam.ps1')
            $expected = "Parameter(s) 'ExtraParam' for  have been documented but not implemented."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with missing input doc' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-MissingInputParam.ps1')
            $expected = "Input parameter(s) 'Parameter' for Test-MissingInputParam have not been documented."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with extra input doc' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-ExtraInputParam.ps1')
            $expected = "Input parameter(s) 'Parameter' for Test-ExtraInputParam have been documented but not implemented."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with missing output doc' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-MissingOutputParam.ps1')
            $expected = "Output type(s) count mismatch for Test-MissingOutputParam, expecting 1 documented outputs but got 0."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with extra output doc' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-ExtraOutputParam.ps1')
            $expected = "Output type(s) count mismatch for Test-ExtraOutputParam, expecting 0 documented outputs but got 1."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with missing requirement inside parameter value' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-MissingRequiredKey.ps1')
            $expected = "Cmdlet doc entry for 'Test-MissingRequiredKey' does not contain the required key 'description'. Found in parameters."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with cmdlet without doc string' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-NoDocString.ps1')
            $expected = "Failed to find any comment block in cmdlet 'Test-NoDocString'."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with invalid YAML string' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-InvalidYaml.ps1')
            $expected = "Failed to convert the first comment block in 'Test-InvalidYaml' from yaml: (Line: 1, Col: 9, Idx: 8) "
            $expected += "- (Line: 1, Col: 9, Idx: 8): Mapping values are not allowed in this context."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with YAML as an array' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-YamlAsArray.ps1')
            $expected = "Expecting cmdlet documentation to be a dictionary not 'List``1'"
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail with an invalid key in the YAML string' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-InvalidKey.ps1')
            $expected = "Cmdlet doc entry for 'Test-InvalidKey' contains an invalid key 'invalid', valid keys are: "
            $expected += "'synopsis', 'description', 'parameters', 'examples', 'inputs', 'outputs', 'notes', 'links', 'extended_doc_fragments'."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail if entry is not the type of the specified list type' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-InvalidListValue.ps1')
            $expected = "Expecting a list for doc entry 'parameters' for 'Test-InvalidListValue'."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should fail if list entry is not the type specified' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-InvalidListEntry.ps1')
            $expected = "Expecting entry of type 'hashtable' for doc entry 'parameters' of 'Test-InvalidListValue' but got 'String'."
            { Format-FunctionWithDoc -LiteralPath $test_path } | Should -Throw $expected
        }

        It 'Should output info on the output structure' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-OutputStructure.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-OutputStructure.md') -Raw

            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-OutputStructure.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-OutputStructure'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should info on the output structure based on a fragment' {
            $expected_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Expected')
            $expected_ps = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-OutputStructureAsFragment.ps1') -Raw
            $expected_md = Get-Content -LiteralPath (Join-Path -Path $expected_path -ChildPath 'Test-OutputStructureAsFragment.md') -Raw

            $fragment_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Fragments')
            $function_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-OutputStructureAsFragment.ps1')

            $actual = Format-FunctionWithDoc -Path $function_path -FragmentPath $fragment_path

            $actual.GetType().FullName | Should -Be 'System.Management.Automation.PSCustomObject'
            $actual.PSObject.TypeNames[0] | Should -Be 'PSDocBuilder.FunctionDoc'
            ($actual.PSObject.Properties.Name | Sort-Object) | Should -Be @(
                'Function',
                'Markdown',
                'Name',
                'Source'
            )

            $actual.Name | Should -Be 'Test-OutputStructureAsFragment'
            $actual.Function | Should -Be $expected_ps
            $actual.Markdown | Should -Be $expected_md
            $actual.Source | Should -Be $function_path
        }

        It 'Should fail if output structure is missing fragment entry' {
            $test_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Test-OutputStructureMissingFragment.ps1')
            $fragment_path = [System.IO.Path]::Combine($PSScriptRoot, 'Data', 'Input', 'Fragments')
            $expected = "Referenced documentation fragment 'fake_fragment' in 'Test-OutputStructureMissingFragment' does not exist."
            { Format-FunctionWithDoc -LiteralPath $test_path -FragmentPath $fragment_path } | Should -Throw $expected
        }
    }
}
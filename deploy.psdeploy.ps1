# Generic module deployment.
#
# ASSUMPTIONS:
#
# * folder structure either like:
#
#   - RepoFolder
#     - This PSDeploy file
#     - ModuleName
#       - ModuleName.psd1
#
#   OR the less preferable:
#   - RepoFolder
#     - RepoFolder.psd1
#
# * Nuget key in $ENV:NugetApiKey
#
# * Set-BuildEnvironment from BuildHelpers module has populated ENV:BHPSModulePath and related variables

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
    Justification='Required in PSDeploy, cannot output to a stream')]
Param ()


Function Optimize-Project {
    param([String]$Path, [String]$DocPath)

    $repo_name = (Get-ChildItem -LiteralPath $Path -Directory -Exclude @('Build', 'Docs', 'Tests')).Name
    $module_path = Join-Path -Path $Path -ChildPath $repo_name
    if (-not (Test-Path -LiteralPath $module_path -PathType Container)) {
        Write-Error -Message "Failed to find the module at the expected path '$module_path'"
        return
    }

    # Build the initial manifest file and get the current export signature
    $manifest_file_path = Join-Path -Path $module_path -ChildPath "$($repo_name).psm1"
    if (-not (Test-Path -LiteralPath $manifest_file_path -PathType Leaf)) {
        Write-Error -Message "Failed to find the module's psm1 file at the expected path '$manifest_file_path'"
        return
    }

    $manifest_pre_template_lines = [System.Collections.Generic.List`1[String]]@()
    $manifest_template_lines = [System.Collections.Generic.List`1[String]]@()
    $manifest_post_template_lines = [System.Collections.Generic.List`1[String]]@()
    $template_section = $false  # $false == pre, $null == template, $true == post

    foreach ($manifest_file_line in (Get-Content -LiteralPath $manifest_file_path)) {
        if ($manifest_file_line -eq '### TEMPLATED EXPORT FUNCTIONS ###') {
            $template_section = $null
        } elseif ($manifest_file_line -eq '### END TEMPLATED EXPORT FUNCTIONS ###') {
            $template_section = $true
        } elseif ($template_section -eq $false) {
            $manifest_pre_template_lines.Add($manifest_file_line)
        } elseif ($template_section -eq $true) {
            $manifest_post_template_lines.Add($manifest_file_line)
        }
    }

    # Read each public and private function and add it to the manifest template
    $public_module_names = [System.Collections.Generic.List`1[String]]@()
    $public_functions_path = Join-Path -Path $module_path -ChildPath Public
    $private_functions_path = Join-Path -Path $module_path -ChildPath Private

    $public_functions_path, $private_functions_path | ForEach-Object -Process {

        if (Test-Path -LiteralPath $_) {
            Format-FunctionWithDoc -Path "$_\*.ps1" | ForEach-Object -Process {

                $manifest_template_lines.Add($_.Function)
                $manifest_template_lines.Add("")  # Add an empty newline so the functions are spaced out.

                $parent = Split-Path -Path (Split-Path -Path $_.Source -Parent) -Leaf
                if ($parent -eq 'Public') {
                    $public_module_names.Add($_.Name)
                    $module_doc_path = Join-Path -Path $doc_path -ChildPath "$($_.Name).md"
                    Set-Content -LiteralPath $module_doc_path -Value $_.Markdown
                }
            }
        }
    }

    # Make sure we add an array of all the public functions and place it in our template. This is so the
    # Export-ModuleMember line at the end exports the correct functions.
    $manifest_template_lines.Add('$public_functions = @(')
    for ($i = 0; $i -lt $public_module_names.Count - 1; $i++) {
        $manifest_template_lines.Add('    ''{0}'',' -f $public_module_names[$i])
    }
    $manifest_template_lines.Add('    ''{0}''' -f $public_module_names[-1])
    $manifest_template_lines.Add(')')

    # Now build the new manifest file lines by adding the templated and post templated lines to the 1 list.
    $manifest_pre_template_lines.AddRange($manifest_template_lines)
    $manifest_pre_template_lines.AddRange($manifest_post_template_lines)
    $manifest_file = $manifest_pre_template_lines -join [System.Environment]::NewLine

    # Now replace the manifest file with our new copy and remove the public and private folders
    if (Test-Path -LiteralPath $private_functions_path) {
        Remove-Item -LiteralPath $private_functions_path -Force -Recurse
    }
    if (Test-Path -LiteralPath $public_functions_path) {
        Remove-Item -LiteralPath $public_functions_path -Force -Recurse
    }
    Set-Content -LiteralPath $manifest_file_path -Value $manifest_file

    return $module_path
}

# Do nothing if the env variable is not set
if (-not $env:BHProjectPath) {
    return
}

# Need to import the current module so we can generate the build artifact
Import-Module -Name $PSScriptRoot\PSDocBuilder\PSDocBuilder.psd1 -Force

# Ensure dir to store Markdown docs exists
$doc_path = Join-Path -Path $env:BHProjectPath -ChildPath 'Docs'
if (-not (Test-Path -LiteralPath $doc_path)) {
    New-Item -Path $doc_path -ItemType Directory > $null
}

# Create dir to store a copy of the build artifact
$build_path = Join-Path -Path $env:BHProjectPath -ChildPath 'Build'
if (Test-Path -LiteralPath $build_path) {
    Remove-Item -LiteralPath $build_path -Force -Recurse
}
New-Item -Path $build_path -ItemType Directory > $null
Copy-Item -LiteralPath $env:BHModulePath -Destination $build_path -Recurse
$module_path = Optimize-Project -Path $build_path -DocPath $doc_path

$is_release = "Release" -in $Tags
if ($is_release) {
    Write-Output -InputObject "TODO: Sign the module"
}

# Verify we can import the module
Import-Module -Name $module_path -Force

# Publish to AppVeyor if we're in AppVeyor
if($env:BHBuildSystem -eq 'AppVeyor') {
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $module_path
            To AppVeyor
            WithOptions @{
                SourceIsAbsolute = $true
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}

# Publish to the PowerShell Gallery if the 'Release' tag is set
if ($is_release) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $module_path
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
                SourceIsAbsolute = $true
            }
        }
    }
}

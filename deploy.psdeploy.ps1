# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

$ErrorActionPreference = 'Stop'

$module_name = (Get-ChildItem -Path ([System.IO.Path]::Combine($DeploymentRoot, 'Build', '*', '*.psd1'))).BaseName
$source_path = [System.IO.Path]::Combine($DeploymentRoot, 'Build', $module_name)

$nupkg_version = $env:APPVEYOR_BUILD_VERSION
if ($env:APPVEYOR_REPO_TAG) {
    $nupkg_version = $env:APPVEYOR_REPO_TAG_NAME
    throw "$($env:APPVEYOR_BUILD_VERSION) - $($env:APPVEYOR_REPO_TAG) - $($env:APPVEYOR_REPO_TAG_NAME) - $nupkg_version"
}

Deploy Module {
    By AppVeyorModule {
        FromSource $source_path
        To AppVeyor
        WithOptions @{
            SourceIsAbsolute = $true
            Version = $nupkg_version
        }
        Tagged AppVeyor
    }

    By PSGalleryModule {
        FromSource $source_path
        To PSGallery
        WithOptions @{
            ApiKey = $env:NugetApiKey
            SourceIsAbsolute = $true
        }
        Tagged Release
    }
}

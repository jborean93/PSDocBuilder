# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

$module_name = (Get-ChildItem -Path ([System.IO.Path]::Combine($DeploymentRoot, 'Build', '*', '*.psd1'))).BaseName
$source_path = [System.IO.Path]::Combine($DeploymentRoot, 'Build', $module_name)

Deploy Module {
    By AppVeyorModule {
        FromSource $source_path
        To AppVeyor
        WithOptions @{
            SourceIsAbsolute = $true
            Version = $env:APPVEYOR_BUILD_VERSION
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

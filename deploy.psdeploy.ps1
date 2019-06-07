# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Deploy Module {
    By AppVeyorModule {
        FromSource ([System.IO.Path]::Combine($DeploymentRoot, 'Build', '*.psd1'))
        To AppVeyor
        WithOptions @{
            SourceIsAbsolute = $true
            Version = $env:APPVEYOR_BUILD_VERSION
        }
        Tagged AppVeyor
    }

    By PSGalleryModule {
        FromSource ([System.IO.Path]::Combine($DeploymentRoot, 'Build', '*.psd1'))
        To PSGallery
        WithOptions @{
            ApiKey = $env:NugetApiKey
            SourceIsAbsolute = $true
        }
        Tagged Release
    }
}

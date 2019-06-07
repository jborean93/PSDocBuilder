# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Deploy Module {
    By AppVeyorModule {
        FromSource (Join-Path -Path $DeploymentRoot -ChildPath Build)
        To AppVeyor
        WithOptions @{
            SourceIsAbsolute = $true
            Version = $env:APPVEYOR_BUILD_VERSION
        }
        Tagged AppVeyor
    }

    By PSGalleryModule {
        FromSource (Join-Path -Path $DeploymentRoot -ChildPath Build)
        To PSGallery
        WithOptions @{
            ApiKey = $env:NugetApiKey
            SourceIsAbsolute = $true
        }
        Tagged Release
    }
}

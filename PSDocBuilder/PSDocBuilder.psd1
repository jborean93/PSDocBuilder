# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

@{
    RootModule = 'PSDocBuilder.psm1'
    ModuleVersion = '0.1.3'
    GUID = '80a19133-7172-4e4b-a687-2e6b8005ab0e'
    Author = 'Jordan Borean'
    Copyright = 'Copyright (c) 2019 by Jordan Borean, Red Hat, licensed under MIT.'
    Description = "Manages a Windows access token.`nSee https://github.com/jborean93/PSDocBuilder for more info"
    PowerShellVersion = '3.0'
    RequiredModules = @(
        'powershell-yaml'
    )
    FunctionsToExport = @(
        'Format-FunctionWithDoc'
    )
    PrivateData = @{
        PSData = @{
            Tags = @(
                "DevOps",
                "Module",
                "Development",
                "Documentation"
            )
            LicenseUri = 'https://github.com/jborean93/PSDocBuilder/blob/master/LICENSE'
            ProjectUri = 'https://github.com/jborean93/PSDocBuilder'
            ReleaseNotes = 'See https://github.com/jborean93/PSDocBuilder/blob/master/CHANGELOG.md'
        }
    }
}

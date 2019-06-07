# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

#Requires -Module powershell-yaml

Set-Variable -Name PSDocBuilderSchema -Scope Script -Option Constant -Force -Value @(
    @{
        Name = 'synopsis'
        Required = $true
        Type = [System.String]
        IsArray = $false
    },
    @{
        Name = 'description'
        Required = $true
        Type = [System.String]
        IsArray = $true
    },
    @{
        Name = 'parameters'
        Required = $false
        Type = [System.Collections.Hashtable]
        IsArray = $true
        Schema = @(
            @{
                Name = 'name'
                Required = $true
                Type = [System.String]
                IsArray = $false
            },
            @{
                Name = 'description'
                Required = $true
                Type = [System.String]
                IsArray = $true
            }
        )
    }
    @{
        Name = 'examples'
        Required = $false
        Type = [System.Collections.Hashtable]
        IsArray = $true
        Schema = @(
            @{
                Name = 'name'
                Required = $true
                Type = [System.String]
                IsArray = $false
            },
            @{
                Name = 'description'
                Required = $true
                Type = [System.String]
                IsArray = $true
            },
            @{
                Name = 'code'
                Required = $true
                Type = [System.String]
                IsArray = $false
            }
        )
    },
    @{
        Name = 'inputs'
        Required = $false
        Type = [System.Collections.Hashtable]
        IsArray = $true
        Schema = @(
            @{
                Name = 'name'
                Required = $true
                Type = [System.String]
                IsArray = $false
            },
            @{
                Name = 'description'
                Required = $true
                Type = [System.String]
                IsArray = $true
            }
        )
    },
    @{
        Name = 'outputs'
        Required = $false
        Type = [System.Collections.Hashtable]
        IsArray = $true
        Schema = @(
            @{
                Name = 'description'
                Required = $false  # Required if structure_fragment is not set
                Type = [System.String]
                IsArray = $true
            },
            @{
                Name = 'structure_fragment'
                Required = $false
                Type = [System.String]
                IsArray = $false
            },
            @{
                Name = 'structure'
                Required = $false
                Type = [System.Collections.Hashtable]
                IsArray = $true
                Schema = @(
                    @{
                        Name = 'name'
                        Required = $true
                        Type = [System.String]
                        IsArray = $false
                    },
                    @{
                        Name = 'description'
                        Required = $true
                        Type = [System.String]
                        IsArray = $false
                    },
                    @{
                        Name = 'type'
                        Required = $false
                        Type = [System.String]
                        IsArray = $false
                    },
                    @{
                        Name = 'when'
                        Required = $false
                        Type = [System.String]
                        IsArray = $false
                    }
                )
            }
        )
    },
    @{
        Name = 'notes'
        Required = $false
        Type = [System.String]
        IsArray = $true
    },
    @{
        Name = 'links'
        Required = $false
        Type = [System.Collections.Hashtable]
        IsArray = $true
        Schema = @(
            @{
                Name = 'link'
                Required = $true
                Type = [System.String]
                IsArray = $false
            },
            @{
                Name = 'text'
                Required = $false
                Type = [System.String]
                IsArray = $false
            }
        )
    },
    @{
        Name = 'extended_doc_fragments'
        Required = $false
        Type = [System.String]
        IsArray = $true
    }
)

### TEMPLATED EXPORT FUNCTIONS ###
# The below is replaced by the CI system during the build cycle to contain all
# the Public and Private functions into the 1 psm1 file for faster importing.

if (Test-Path -LiteralPath $PSScriptRoot\Public) {
    $public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
} else {
    $public = @()
}
if (Test-Path -LiteralPath $PSScriptRoot\Private) {
    $private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
} else {
    $private = @()
}

# dot source the files
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

$public_functions = $public.Basename

### END TEMPLATED EXPORT FUNCTIONS ###

Export-ModuleMember -Function $public_functions

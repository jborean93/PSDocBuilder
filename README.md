# PSDocBuilder

[![Build status](https://ci.appveyor.com/api/projects/status/ocurnrxf16dkwsnk?svg=true)](https://ci.appveyor.com/project/jborean93/psdocbuilder)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSDocBuilder.svg)](https://www.powershellgallery.com/packages/PSDocBuilder)

Generate PowerShell function/cmdlet and Markdown documentation from yaml.

_Note: I wrote this before I found out about [platyPS](https://github.com/PowerShell/platyPS) and while there are things that would be nice to have there this is mostly just a test repo and not planned to be maintained_


## Info

Generating documentation can be tedious and can have a lot of duplicate
information. `PSDocBuilder` is designed for modules to document the bare
minimum in their source repo and have this module generate the proper
documentation when being built.

This module includes the following cmdlets;

* [Format-FunctionWithDoc](Docs/Format-FunctionWithDoc.ps1): Generate documentation for functions in a script.

When creating a module, the documentation string is set as a yaml string with
the following keys;

```yaml
---
synopsis: A string that is set as the brief synopsis of the cmdlet. This a required key.
description:
- A list of string that is the description of the cmdlet. Each entry can include multiple sentances as well as break
  over a newline like this.
- A new entry will be placed in a new paragraph in the relevant section.
parameters:
- name: The name of the parameter, each parameter set in the cmdlet should be documented here.
  description:
  - A list of strings that describe the parameter, same rules as the 'description' key above.
examples:
- name: Short name for the example, you can have multiple examples, just add a new entry.
  description:
  - A list of strings that describe the example.
  code: |-
    The full example of the cmdlet.
inputs:
- name: The parameter name the input relates to.
  description:
  - A list of strings that describe the input value.
outputs:
- description:
  - A list of strings that describes the output.
  # Contains a list hashs that describe each property that is output, useful for PSCustomObjects but not mandatory
  structure:
  - name: The name of property the entry describes.
    description:
    - A list of strings that describe the property value.
    type: An optional type as a string for the property.
    when: An optional value that states when the property exists or is set in the object.
  structure_fragment: An extended doc fragment that will replace the 'description' and 'structure' values based on the
    value inside the fragment. See below for more info on extended doc fragments.
notes:
- A list of strings that include extra notes on the cmdlet.
links:
- link: A link to add to the docs.
  text: Optional header/name for the link.
extended_doc_fragments:
- A list of doc fragment files that stores common values between cmdlet docs.
```

The `Format-FunctionWithDoc` takes in the doc string and merges it with the
metadata of the cmdlet to produce a common format for the cmdlet docstring
as well as a Markdown document. If you wish to reference another cmdlet
markdown document as a string, set the value to `C(My-Cmdlet)`. This will
automatically be replace with `[My-Cmdlet](My-Cmdlet.md)` in the final markdown
document produced.

### Document Fragments

The doc string can contain the key `extended_doc_fragments` which allows a
maintainer to store common documentation elements inside a separate file and
refer to that in multiple locations. The fragment must follow the same
structure as the full module doc structure but no keys are mandatory for the
fragment. When referring to the doc fragment, the value should be the filename
of the yaml fragment without the extension. The `Format-FunctionWithDoc` will
automatically parse the fragment and merge the fragment hash into the main doc
structure.


## Requirements

These cmdlets have the following requirements

* PowerShell v3.0 or newer (PSCore included)


## Installing

The easiest way to install this module is through
[PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/overview).
This is installed by default with PowerShell 5 but can be added on PowerShell
3 or 4 by installing the MSI [here](https://www.microsoft.com/en-us/download/details.aspx?id=51451).

Once installed, you can install this module by running;

```powershell
# Install for all users
Install-Module -Name PSDocBuilder

# Install for only the current user
Install-Module -Name PSDocBuilder -Scope CurrentUser
```

If you wish to remove the module, just run
`Uninstall-Module -Name PSDocBuilder`.

If you cannot use PowerShellGet, you can still install the module manually,
by using the script cmdlets in the script [Install-ModuleNupkg.ps1](https://gist.github.com/jborean93/e0cb0e3aabeaa1701e41f2304b023366).

```powershell
# Enable TLS1.1/TLS1.2 if they're available but disabled (eg. .NET 4.5)
$security_protocols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::SystemDefault
if ([Net.SecurityProtocolType].GetMember("Tls11").Count -gt 0) {
    $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls11
}
if ([Net.SecurityProtocolType].GetMember("Tls12").Count -gt 0) {
    $security_protocols = $security_protocols -bor [Net.SecurityProtocolType]::Tls12
}
[Net.ServicePointManager]::SecurityProtocol = $security_protocols

# Run the script to load the cmdlets and get the URI of the nupkg
$install_script_uri = 'https://gist.github.com/jborean93/e0cb0e3aabeaa1701e41f2304b023366/raw/Install-ModuleNupkg.ps1'
$install_script = (Invoke-WebRequest -Uri $install_script_uri).Content

################################################################################################
# Make sure you check the script at the URI first and are happy with the script before running #
################################################################################################
Invoke-Expression -Command $install_script

# Get the URI to the nupkg on the gallery
$gallery_uri = Get-PSGalleryNupkgUri -Name PSDocBuilder

# Install the nupkg for the current user, add '-Scope AllUsers' to install for all users (requires admin privileges)
Install-PowerShellNupkg -Uri $gallery_uri
```

_note: I can't stress this enough, make sure you review the script specified by `$install_script_uri` before running the above_

If you wish to remove a module installed with the above method you can run;

```powershell
$module_path = (Get-Module -Name PSDocBuilder -ListAvailable).ModuleBase
Remove-Item -LiteralPath $module_path -Force -Recurse
```


## Contributing

Contributing is quite easy, fork this repo and submit a pull request with the
changes. To test out your changes locally you can just run `.\build.ps1` in
PowerShell. This script will ensure all dependencies are installed before
running the test suite.

_Note: this requires PowerShellGet or WMF 5+ to be installed_

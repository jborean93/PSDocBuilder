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

```
# Install for all users
Install-Module -Name PSDocBuilder

# Install for only the current user
Install-Module -Name PSDocBuilder -Scope CurrentUser
```

If you wish to remove the module, just run
`Uninstall-Module -Name PSDocBuilder`.

If you cannot use PowerShellGet, you can still install the module manually,
here are some basic steps on how to do this;

1. Download the latext zip from GitHub [here](https://github.com/jborean93/PSDocBuilder/releases/latest)
2. Extract the zip
3. Copy the folder `PSDocBuilder` inside the zip to a path that is set in `$env:PSModulePath`. By default this could be `C:\Program Files\WindowsPowerShell\Modules` or `C:\Users\<user>\Documents\WindowsPowerShell\Modules`
4. Reopen PowerShell and unblock the downloaded files with `$path = (Get-Module -Name PSDocBuilder -ListAvailable).ModuleBase; Unblock-File -Path $path\*.psd1;`
5. Reopen PowerShell one more time and you can start using the cmdlets

_Note: You are not limited to installing the module to those example paths, you can add a new entry to the environment variable `PSModulePath` if you want to use another path._


## Contributing

Contributing is quite easy, fork this repo and submit a pull request with the
changes. To test out your changes locally you can just run `.\build.ps1` in
PowerShell. This script will ensure all dependencies are installed before
running the test suite.

_Note: this requires PowerShellGet or WMF 5+ to be installed_

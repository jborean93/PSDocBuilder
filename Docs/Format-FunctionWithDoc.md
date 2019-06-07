# Format-FunctionWithDoc

## SYNOPSIS

Generate PowerShell and Markdown docs from cmdlet.


## SYNTAX

```
Format-FunctionWithDoc [-Path] <string[]> [-FragmentPath <string>] [<CommonParameters>]

Format-FunctionWithDoc -LiteralPath <string[]> [-FragmentPath <string>] [<CommonParameters>]
```


## DESCRIPTION

The `Format-FunctionWithDoc` cmdlet takes in an existing cmdlet and generates the PowerShell and Markdown documentation based on common schema set by `PSDocBuilder` and the actual cmdlet's metadata. The advantage of using a common documentation schema and build tools is that it guarantees the output docs to follow a common format and add extra functionality like sharing common doc snippets in multiple modules.


## EXAMPLES

### EXAMPLE 1: Generate a single module file from a module.

```powershell
$public_script_path = ".\Module\Public\*.ps1"
$private_script_path = ".\Module\Private\*.ps1"
$doc_path = ".\Docs"
$module_file = ".\Build\Module.psm1"

Set-Content -Path $module -Value "# Copyright 2019 - Author Name"

$public_cmdlets = [System.Collections.Generic.List`1[System.String]]@()
Format-FunctionWithDoc -Path $public_script_path, $private_script_path | For-EachObject -Process {
    $parent = Split-Path -Path (Split-Path -Path $_.Source -Parent) -Leaf

    if ($parent -eq 'Public') {
        $public_cmdlets.Add($_.Name)
        Set-Content -Path (Join-Path -Path $doc_path -Child Path "$($_.Name).md") -Value $_.Markdown
    }

    Add-Content -Path $module -Value $_.Function
}

$module_footer = @"
$public_functions = @(
    '$($public_cmdlets -join "',`r`n'")'
)

Export-ModuleMember -Functions $public_functions
"@

Add-Content -Path $module -Value $module_footer

```

Uses the cmdlet to format an existing module that contains scripts in the `Private` and `Public` directory. The
formatted functions are placed into single module file in the `Build` directory.


## PARAMETERS

### -Path

Specifies the path to one ore more locations to a PowerShell script that contains one or more cmdlets. These cmdlets are then parsed and used to generate both PowerShell and Markdown documents from the existing metadata. Wildcard characters are permitted.

Use a dot (`.`) to specify the current location. Use the wildcard character (`*`) to specify all items in that location.

```
Type: System.String[]
Aliases: None
Default value: None
Accept wildcard characters: True
Parameter Sets:
  Path:
    Required: True
    Position: 0
    Accept pipeline input: True (ByValue, ByPropertyName)
```

### -LiteralPath

Specifies the path to one or more locations to a PowerShell script that contains one or more cmdlet. These cmdlets are then parsed and used to generate both PowerShell and Markdown documents from the existing metadata.

The value for `LiteralPath` is used exactly as it is typed, use `Path` if you wish to use wildcard characters instead.

```
Type: System.String[]
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  LiteralPath:
    Required: True
    Position: Named
    Accept pipeline input: True (ByPropertyName)
```

### -FragmentPath

The path to a directory that contains extra document fragments to use during the metadata parsing. This directory should contain one or more `*.yml` files which contains common keys and values to be merged into the cmdlet metadata. This is referenced by the `extended_doc_fragments` key in the cmdlet metadata.

```
Type: System.String
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: False
    Position: Named
    Accept pipeline input: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).


## INPUTS

### [System.String[]] - Path (ByValue, ByPropertyName)

You can pipe a string or property with the name of `Path` to this cmdlet.

### [System.String[]] - LiteralPath (ByPropertyName)

You can pipe a property with the name of `LiteralPath` to this cmdlet.


## OUTPUTS

### Parameter Sets - (All)

Output Types: `[PSDocBuilder.FunctionDoc]`

An object for each cmdlet inside the script(s) specified by `Path` or `LiteralPath`. The object has the name of the cmdlet as well as the formatted function with the PS and Markdown documentation.

| Property | Description | Type | Output When |
|----------|-------------|------|-------------|
|Name|The name of the cmdlet.|||
|Source|The full path to the source file the cmdlet was extracted from.|||
|Function|The full PowerShell function with the embedded PowerShell document. This value can then be used to populate the final build artifact the caller is creating.|||
|Markdown|The full Markdown document of the function. This value can be placed in a file in the output directory of the callers choice.|||


## NOTES

Each function found in the path will be dot sourced so the cmdlet can generate the Markdown syntax documentation. Any special types used by the cmdlet will need to be loaded before this will work.

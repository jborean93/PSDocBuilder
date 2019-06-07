# Test-CustomType

## SYNOPSIS

Synopsis for Test-CustomType.


## SYNTAX

```
Test-CustomType [-CustomType] <TestClass> [<CommonParameters>]
```


## DESCRIPTION

The description for Test-CustomType.


## EXAMPLES

### EXAMPLE 1: Example 1

```powershell
$obj = New-Object -TypeName PSDocBuilder.TestClass
$obj = Test-CustomType -CustomType $obj

```

Description for Example 1


## PARAMETERS

### -CustomType

A PSDocBuilder.TestClass object that is a dynamic type.

```
Type: PSDocBuilder.TestClass
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: True
    Position: Named
    Accept pipeline input: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).


## INPUTS

None


## OUTPUTS

### Parameter Sets - (All)

Output Types: `[PSDocBuilder.TestClass]`

The custom type is returned back.
# Test-DynamicParam

## SYNOPSIS

Test cmdlet with dynamic parameters.


## SYNTAX

```
Test-DynamicParam [-Parameter1] <string> [-Switch] [<CommonParameters>]
```


## DESCRIPTION

Description for Test-DynamicParam.


## EXAMPLES

None


## PARAMETERS

### -Parameter1

The description for the `-Parameter1` parameter.

```
Type: System.String
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: True
    Position: 0
    Accept pipeline input: False
```

### -Switch

The description for the `-Switch` parameter.

```
Type: System.Management.Automation.SwitchParameter
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  Switch:
    Required: False
    Position: Named
    Accept pipeline input: False
```

### -DynamicParam (Dynamic)

The description for the `-DynamicParam` parameters. This parameter is defined in a DynamicParam block and tests host PSDocBuilder handles these params.

```
Type: System.Object
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets: {}
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).


## INPUTS

None
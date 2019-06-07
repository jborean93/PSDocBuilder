# Test-FunctionInlineParam

## SYNOPSIS

Test synopsis for an advanced function with inline params.


## SYNTAX

```
Test-FunctionInlineParam [-Parameter1] <string> [-Parameter5 <hashtable>] [-Default <string>] [-DefaultArray
    <string[]>] [-Choice <Object>] [-SwitchParam] [<CommonParameters>]

Test-FunctionInlineParam [-Parameter2] <int> [-Parameter5] <hashtable> [-Default <string>] [-DefaultArray
    <string[]>] [-Choice <Object>] [-SwitchParam] [<CommonParameters>]

Test-FunctionInlineParam [-Parameter3] <long> [-Parameter5 <hashtable>] [-Default <string>] [-DefaultArray
    <string[]>] [-Choice <Object>] [-SwitchParam] [<CommonParameters>]

Test-FunctionInlineParam [-Parameter4] <byte> [-Parameter5 <hashtable>] [-Default <string>] [-DefaultArray
    <string[]>] [-Choice <Object>] [-SwitchParam] [<CommonParameters>]
```


## DESCRIPTION

Some description for an advanced inline param function. This sentance should continue on and eventually wrap at around 120 characters long. The sentance should not be in a separate paragraph. Also add a link to a cmdlet with [Cmdlet-Name](Cmdlet-Name.md).

Should be in a new paragraph.


## EXAMPLES

### EXAMPLE 1: Test-FunctionInlineParam Example 1

```powershell
$res = Test-FunctionInlineParam -Parameter1 "Some really long string value to test out link length." -Parameter3 1 -Choice "Choice 1" -SwithParam
$output = "Hi: $($res)"

Write-Output $output
```

The first example of Test-FunctionInlineParam 1. This sentance adds some filler to make sure that it tests the 120
character limit for a PS doc.

Another entry for example 1 that tests out a new paragraph in the description.

### EXAMPLE 2: Test-FunctionInlineParam Example 2 scenario

```powershell
[PSCustomObject]@{Parameter2 = "abc"} | Test-FunctionInlineParam -Parameter4 123 -Default "different value"
```

A simple description for the 2nd example of Test-FunctionInlineParam.


## PARAMETERS

### -Parameter1

The description for Parameter1.

```
Type: System.String
Aliases: MainAlias1, MainAlias2
Default value: None
Accept wildcard characters: True
Parameter Sets:
  TestPS1, TestPS2:
    Required: True
    Position: 0
    Accept pipeline input: True (ByValue)
```

### -Parameter2

A long winded description for Parameter1 that spans across multiple lines. This should also fit inside one paragraph because it's in one yaml list entry.

A new paragraph should be set for this entry because it is in another yaml list entry.

```
Type: System.Int32
Aliases: Parameter2Alias
Default value: None
Accept wildcard characters: False
Parameter Sets:
  TestPS3:
    Required: True
    Position: 0
    Accept pipeline input: True (ByValue, ByPropertyName)
```

### -Parameter3

The third parameter, nothing special.

```
Type: System.Int64
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  TestPS1:
    Required: True
    Position: 1
    Accept pipeline input: True (ByPropertyName)
```

### -Parameter4

The fourth parameter.

```
Type: System.Byte
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  TestPS2:
    Required: True
    Position: 1
    Accept pipeline input: False
```

### -Parameter5

The fifth parameter.

```
Type: System.Collections.Hashtable
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  TestPS3:
    Required: True
    Position: 1
    Accept pipeline input: False
  (All):
    Required: False
    Position: Named
    Accept pipeline input: True (ByPropertyName)
```

### -Default

Should show the default value in the markdown doc.

```
Type: System.String
Aliases: None
Default value: Default
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: False
    Position: Named
    Accept pipeline input: False
```

### -DefaultArray

Test to make sure we don't choke on an expression as a default value.

```
Type: System.String[]
Aliases: None
Default value: '@()'
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: False
    Position: Named
    Accept pipeline input: False
```

### -Choice

Should show the valid choices in the markdown doc.

```
Type: System.Object
Aliases: None
Default value: None
Accept wildcard characters: False
Parameter Sets:
  (All):
    Required: False
    Position: Named
    Accept pipeline input: False
```

### -SwitchParam

The switch parameter.

```
Type: System.Management.Automation.SwitchParameter
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

### [System.String] - Parameter1 (ByValue)

A description for the first input parameter, this should only have the ByVal input flags.

### [System.Int32] - Parameter2 (ByValue, ByPropertyName)

A description for the 2nd parameter input. This should have both the `ByVal` and `ByPropertyName` flags set. I am also going to add a further sentance to this description.

### [System.Int64] - Parameter3 (ByPropertyName)

A description for the 3rd input parameter.

### [System.Collections.Hashtable] - Parameter5 (ByPropertyName)

Tests out multiple Parameter entries for a parameter.


## NOTES

Some note 1, this should be in a single paragraph even though there are multiple sentances. Added some more filler to test out the line lengths.

Some note 2 in another paragraph.


## RELATED LINKS

* [https://www.google.com](https://www.google.com)
* [Google's Website](https://www.google.com)
* [Another-Function](Another-Function.md)
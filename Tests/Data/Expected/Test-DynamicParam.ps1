Function Test-DynamicParam {
    <#
    .SYNOPSIS
    Test cmdlet with dynamic parameters.

    .DESCRIPTION
    Description for Test-DynamicParam.

    .PARAMETER Parameter1
    [System.String]
    The description for the `-Parameter1` parameter.

    .PARAMETER Switch
    [System.Management.Automation.SwitchParameter]
    The description for the `-Switch` parameter.

    .PARAMETER DynamicParam
    [System.Object]
    The description for the `-DynamicParam` parameters. This parameter is defined in a DynamicParam block and tests
    host PSDocBuilder handles these params.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, Position=0)]
        [System.String]
        $Parameter1,

        [Parameter(ParameterSetName='Switch')]
        [Switch]
        $Switch
    )

    DynamicParam {
        if ($PSCmdlet.ParameterSetName -eq 'Switch') {
            $attr = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $attr.ParameterSetName = 'Switch'
            $attr.Mandatory = $false

            $attr_coll = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attr_coll.Add($attr)

            $dyn_param = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @(
                'DynamicParam', [System.Int32], $attr_coll
            )

            $param_dict = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $param_dict.Add('DynamicParam', $dyn_param)
            return $param_dict
        }
    }

    Process {
        return
    }
}
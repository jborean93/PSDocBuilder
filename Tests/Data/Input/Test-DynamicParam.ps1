Function Test-DynamicParam {
    <#
    ---
    synopsis: Test cmdlet with dynamic parameters.
    description:
    - Description for Test-DynamicParam.
    parameters:
    - name: Parameter1
      description:
      - The description for the `-Parameter1` parameter.
    - name: Switch
      description:
      - The description for the `-Switch` parameter.
    - name: DynamicParam
      description:
      - The description for the `-DynamicParam` parameters. This parameter is defined in a DynamicParam block and tests
        host PSDocBuilder handles these params.
    examples: []
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
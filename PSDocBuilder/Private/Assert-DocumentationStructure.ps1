# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Assert-DocumentationStructure {
    <#
    ---
    synopsis: Validates the doc structure.
    description:
    - Validates the documentation structure passed from a cmdlet.
    parameters:
    - name: Schema
      description:
      - The schema object to validate against, if documenting against the root document element, this value should be
        `$script:PSDocBuilderSchema`.
    - name: Documentation
      description:
      - The actual documentation hashtable to validate against the schema.
    - name: Name
      description:
      - A human friendly name to describe where the doc was derived from. This is used for error reporting.
    - name: FoundIn
      description:
      - A list that contains the keys the current `Documentation` element was found in. This is used for error
        reporting.
    - name: IsFragment
      description:
      - States the `Documentation` value is a fragment which relaxes the required key rules in the schema.
    examples:
    - name: Validate schema of PS metadata doc.
      description:
      - Validates the structure of the yaml doc located in a PowerShell function.
      code: |
        Assert-DocumentationStructure -Schema $script:PSDocBuilderSchema -Documentation $cmdlet_doc -Name 'Test-Function'
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable[]]
        $Schema,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]
        $Documentation,

        [System.String]
        $Name = 'Unspecified',

        [System.String[]]
        $FoundIn = @(),

        [Switch]
        $IsFragment
    )

    Function Add-FoundInError {
        Param (
            [Parameter(ValueFromPipeline=$true)]
            [System.String]
            $Message,

            [AllowEmptyCollection()]
            [System.String[]]
            $FoundIn
        )

        if ($FoundIn.Length -gt 0) {
            $Message += " Found in $($FoundIn -join " -> ")."
        }

        return $Message
    }

    # Loop through the keys to make sure they exist in the schema.
    foreach ($kvp in $Documentation.GetEnumerator()) {
        if ($kvp.Key -notin $Schema.Name) {
            $msg = "Cmdlet doc entry for '$Name' contains an invalid key '$($kvp.Key)', valid keys are: '$($Schema.Name -join "', '")'."
            $msg = $msg | Add-FoundInError -FoundIn $FoundIn
            throw $msg
        }
    }

    # Loop through the schema to make sure the values are the correct type and required ones are present.
    foreach ($schema_entry in $Schema) {
        # Raise an error if a required key is not set and the current doc is not a fragment.
        if ((-not $Documentation.ContainsKey($schema_entry.Name)) -and $schema_entry.Required -and -not $IsFragment) {
            $msg = "Cmdlet doc entry for '$Name' does not contain the required key '$($schema_entry.Name)'."
            $msg = $msg | Add-FoundInError -FoundIn $FoundIn
            throw $msg
        } elseif (-not $Documentation.ContainsKey($schema_entry.Name)) {
            # Set the default value and continue if the key is not set
            $value = $null
            if ($schema_entry.IsArray) {
                $value_type = 'System.Collections.Generic.List`1[System.Object]'
                $value = New-Object -TypeName $value_type
            } elseif ($schema_entry.Type -eq [System.String]) {
                $value = ""
            }
            $Documentation."$($schema_entry.Name)" = $value
            continue
        }

        # Verify the type
        $doc_value = $Documentation."$($schema_entry.Name)"
        if ($schema_entry.IsArray) {
            if ($doc_value -isnot [System.Collections.Generic.List`1[Object]]) {
                if ($doc_value -is $schema_entry.Type) {
                    $doc_value = [System.Collections.Generic.List`1[System.Object]]@($doc_value)
                    $Documentation."$($schema_entry.Name)" = $doc_value
                } else {
                    $msg = "Expecting a list for doc entry '$($schema_entry.Name)' for '$Name'."
                    $msg = $msg | Add-FoundInError -FoundIn $FoundIn
                    throw $msg
                }
            }
        } else {
            $doc_value = @($doc_value)
        }
        foreach ($val in $doc_value) {
            if ($val -isnot $schema_entry.Type) {
                $msg = "Expecting entry of type '$($schema_entry.Type)' for doc entry '$($schema_entry.Name)' of '$Name' but got '$($val.GetType().Name)'."
                $msg = $msg | Add-FoundInError -FoundIn $FoundIn
                throw $msg
            }

            # Validate the sub schema.
            if ($schema_entry.ContainsKey('Schema')) {
                $assert_params = @{
                    Schema = $schema_entry.Schema
                    Documentation = $val
                    Name = $Name
                    FoundIn = ($FoundIn + $schema_entry.Name)
                    IsFragment = $IsFragment.IsPresent
                }
                Assert-DocumentationStructure @assert_params
            }
        }
    }
}
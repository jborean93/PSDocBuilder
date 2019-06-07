# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Merge-Hashtable {
    <#
    ---
    synopsis: Merge 2 hashtable together.
    description:
    - Merges two hashtable into the original input object.
    parameters:
    - name: InputObject
      description:
      - The original hashtable that will be used as the merge destination.
    - name: Hashtable
      description:
      - The hashtable to merge into `InputObject`.
    examples:
    - name: Merge a hashtable
      description: Merges the hashtable `$b` into the hashtable `$a`.
      code: |
        $a = @{
            Key = "key"
            Value = "value"
        }
        $b = @{
            Value = "value2"
            Extra = "extra value"
        }

        Merge-Hashtable -InputObject $a -Hashtable $b

        Write-Output -InputObject $a
        # Will result in
        #     Key = "key"
        #     Value = "extra value"
        #     Extra = "extra value"
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]
        $InputObject,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]
        $Hashtable
    )

    foreach ($kvp in $Hashtable.GetEnumerator()) {
        $InputObject."$($kvp.Key)" += $kvp.Value
    }
}
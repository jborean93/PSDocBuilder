# Copyright: (c) 2019, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Format-IndentAndWrapping {
    <#
    ---
    synopsis: Format a string to the set indentation and wrapping rules.
    description:
    - Takes in a string or array of strings that are then indented and wrapped at a character line length based on the
      input parameters.
    parameters:
    - name: Value
      description:
      - The string or array of strings to wrap. Each entry in an array will be placed in a new paragraph.
    - name: Indent
      description:
      - The number of spaces to indent each line.
    - name: MaxLength
      description:
      - The maximum characters in a line before the remaining values are placed in a new line. The value includes the
        length of the indentation added by the cmdlet. Set to `0` for no maximum line length.
    examples:
    - name: Format a string with no indentation and wrapping.
      description:
      - Will format the input value with no indentation and wrapping.
      code: |
        $input_string = @"
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam imperdiet eu lacus at iaculis.
        Quisque tempus erat sit amet vulputate iaculis. Morbi felis dui, scelerisque vel purus eu,
        posuere fermentum risus
        "@

        Format-IndentAndWrapper -Value $input_string
    - name: Format a string up to 120 characters and indent with 4 spaces.
      description:
      - Will format the input string with 4 spaces as an indentation and cut it off at 120 characters long.
      code: |
        $input_string = @"
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam imperdiet eu lacus at iaculis.
        Quisque tempus erat sit amet vulputate iaculis. Morbi felis dui, scelerisque vel purus eu,
        posuere fermentum risus
        "@

        Format-IndentAndWrapper -Value $input_string -Indent 4 -MaxLength 120
    inputs:
    - name: Value
      description:
      - The input string can be passed in as a value.
    outputs:
    - description:
      - The indented and wrapped string based on the input parametes.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [System.String[]]
        $Value,

        [System.Int32]
        $Indent = 0,

        [System.Int32]
        $MaxLength = 0
    )

    Begin {
        $lines = [System.Collections.Generic.List`1[System.String]]@()
    }

    Process {
        foreach ($entry in $Value) {
            $entry = $entry.Trim()
            foreach ($line in $entry.Split([System.Char[]]@("`r", "`n"))) {
                $words = $line.Split([System.Char[]]@(' '))

                $new_lines = [System.Collections.Generic.List`1[System.String]]@()
                $new_line = New-Object -TypeName System.Text.StringBuilder -ArgumentList @((" " * $Indent), $MaxLength)

                foreach ($word in $words) {
                    if ($new_line.Length -eq $Indent) {
                        # Started on a newline, don't add a space.
                        $new_line.Append($word) > $null
                    } elseif ($MaxLength -gt 0 -and ($word.Length + $new_line.Length + 2) -gt $MaxLength) {
                        # Won't fit in the line, finish off the line and start a new one.
                        $new_lines.Add($new_line.ToString()) > $null
                        $new_line = New-Object -TypeName System.Text.StringBuilder -ArgumentList @(((" " * $Indent) + $word), $MaxLength)
                    } else {
                        # Just a normal work, add a space then the word.
                        $new_line.Append(" $word") > $null
                    }
                }

                # Finally add the remaining chars in the line.
                if ($new_line.Length -gt 0) {
                    $new_lines.Add($new_line.ToString())
                }

                # Loop through the lines and make sure the ends have been trimmed.
                foreach ($new_line in $new_lines) {
                    $new_line = $new_line.TrimEnd()
                    $lines.Add($new_line)
                }
            }

            $lines.Add("")  # Add an empty line for each new entry.
        }
    }

    End {
        return ($lines -join [System.Environment]::NewLine).TrimEnd()
    }
}
# Define the directory containing the files
$directoryPath = "C:\HLAG\Users\MBELLLE\EDI\EDO\*.xml"

# Function to apply replacements
function Apply-Replacements {
    param (
        [string]$line
    )

    $replacements = @(
        '<pd_type>SAD</pd_type>','<pd_type/>',
        '<nil/>', '<nil>Y</nil>',
        '22K2', '22T0',
        '22K1', '22T0',
        '25K1', '22T0',
        '45R5', '45R0',
        'CNSTG', 'CNNSA',
        'CNJUJ', 'CNNGB',
        'EEMUG', 'DEHAM',
	'3402000000', '3402900000',
        '0000000000', '8609000000',
        '9817000000', '8703243100',
        '9995000000', '6911900000',
        '3038310000', '3004100000',
        '8430410000', '8703243100',
        '1993000000', '3302900000',
        '3924000000', '3924900000',
        '0712000000', '3402900000',
        '2208000000', '2208300000',
        '5407000000', '5407100000',
        '8450000000', '8450111000',
        '8716800000', '8703243100',
        '1823000000', '3302900000',
        '3143000000', '3302900000',
        '3926901000', '3302900000',
        '8431390000', '8431100000',
        '9804000000', '8703243100',
        '4015110000', '4015190000',
        '8535000000', '8535100000',
        '4011000000', '4011100000',
        '2204000000', '2204100000',
        '8428900000', '8431100000',
        '9905000000', '6911900000',
        '8704211000', '8703243100',
        '6601000000', '6911900000',
        '9919100000', '6911900000',
        '9005000000', '6911900000',
        '0900000000', '0902300000',
        '6103000000', '6103100000',
        '9801000000', '8708290000',
        '3824900000', '3824910000',
        '9805000000', '6911900000',
        '0206000000', '0206100000',
        'OldString1', 'NewString1'
    )

    # Loop through each replacement pair
    for ($i = 0; $i -lt $replacements.Length; $i += 2) {
        $line = $line -replace $replacements[$i], $replacements[$i + 1]
    }

    return $line
}

# Get the files
$files = Get-ChildItem $directoryPath

foreach ($file in $files) {
    try {
        # Read the original content of the file
        $content = Get-Content -Path $file.FullName -Encoding UTF8
    } catch {
        Write-Host "Error reading file: $($file.FullName). Error: $_"
        continue
    }

    # Initialize a variable to store the modified content
    $modifiedContent = @()
    
    foreach ($line in $content) {
        # Apply the replacements using the function
        $originalLine = $line
        $line = Apply-Replacements -line $line

        # Log if the line was modified
        if ($originalLine -ne $line) {
            Write-Host "File: $($file.FullName)"
            Write-Host "Original: $originalLine"
            Write-Host "Replaced: $line"
        }

        # Add the modified line to the content array
        $modifiedContent += $line
    }

    try {
        # Write the modified content back to the file
        $modifiedContent | Set-Content -Path $file.FullName -Encoding UTF8
        Write-Host "Successfully modified file: $($file.FullName)"
    } catch {
        Write-Host "Error writing to file: $($file.FullName). Error: $_"
    }
}

Write-Host "All files processed."

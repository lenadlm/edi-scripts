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
        '0000000000', '3924900000',
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
        'OldString1', 'NewString1'
    )

    # Loop through each replacement pair
    for ($i = 0; $i -lt $replacements.Length; $i += 2) {
        $line = $line -replace $replacements[$i], $replacements[$i + 1]
    }

    return $line
}

# Initialize progress tracking
$files = Get-ChildItem $directoryPath
$totalFiles = $files.Count
$counter = 0

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

    # Update progress
    $counter++
    Write-Progress -Activity "Processing files" -Status "$counter out of $totalFiles" -PercentComplete (($counter / $totalFiles) * 100)
}

Write-Host "All files processed."

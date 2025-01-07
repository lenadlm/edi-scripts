# Define the directory containing the files
$directoryPath = "C:\Users\...\MNF"

# Define the path to the replacements file
$replacementsFilePath = "C:\Users\...\replacements.txt"

# Function to apply replacements
function Apply-Replacements {
    param (
        [string]$line,
        [array]$replacements
    )

    for ($i = 0; $i -lt $replacements.Length; $i++) {
        $replacement = $replacements[$i] -split ","
        $oldValue = $replacement[0].Trim()
        $newValue = $replacement[1].Trim()

        $line = $line -replace [regex]::Escape($oldValue), $newValue
    }
    return $line
}

# Load the replacements from the file
if (Test-Path -Path $replacementsFilePath) {
    $replacements = Get-Content -Path $replacementsFilePath
} else {
    Write-Host "Replacements file not found at $replacementsFilePath"
    exit
}

# Get only .xml files in the specified directory
$files = Get-ChildItem -Path $directoryPath -Filter "*.xml" -File

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
    $tdBillCode = ""  # To track the current td_bill_code

    foreach ($line in $content) {
        # Check for td_bill_code in the current line
        if ($line -match '<td_bill_code>(.*?)</td_bill_code>') {
            $tdBillCode = $matches[1]  # Extract the content of td_bill_code
        }

        # Apply the replacements using the function
        $originalLine = $line
        $line = Apply-Replacements -line $line -replacements $replacements

        # Log if the line was modified
        if ($originalLine -ne $line) {
            Write-Host ("TD Bill Code:".PadRight(25) + "$tdBillCode")
            Write-Host "Original Line: $originalLine"
            Write-Host "Replaced Line: $line"
            Write-Host "" 
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

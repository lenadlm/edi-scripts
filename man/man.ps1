# Define the directory containing the files 
$directoryPath = "C:\...\EDI\MAN"

# Define the URL for the replacements file
$replacementsFileUrl = "https://raw.githubusercontent.com/lenadlm/edi-scripts/main/replacements.txt"

# Function to apply replacements
function Apply-Replacements {
    param (
        [string]$line,
        [array]$replacements
    )

    foreach ($replacement in $replacements) {
        # Ensure valid replacement format
        $splitReplacement = $replacement -split ","
        if ($splitReplacement.Count -ge 2) {
            $oldValue = $splitReplacement[0].Trim()
            $newValue = $splitReplacement[1].Trim()
            $line = $line -replace [regex]::Escape($oldValue), $newValue
        }
    }
    return $line
}

# Download the replacements file content
try {
    $replacements = Invoke-RestMethod -Uri $replacementsFileUrl
    $replacements = $replacements -split "`r?`n"  # Handle Windows/Linux line endings
} catch {
    Write-Host "Error fetching replacements file from URL: $_"
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

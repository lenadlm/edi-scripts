$files = Get-ChildItem "C:\HLAG\Users\MBELLLE\EDI\EDO\*.xml"

foreach ($file in $files) {
    try {
        # Try to read the original content of the file line by line
        $content = Get-Content $file.FullName
    } catch {
        Write-Host "Error reading file: $($file.FullName). Error: $_"
        continue  # Skip to the next file if an error occurs
    }

    # Initialize a variable to store the modified content
    $modifiedContent = @()

    foreach ($line in $content) {
        try {
            # Store the original line
            $originalLine = $line

            # Apply the replacements to the line and update the $line variable
            $line = $line `
            -replace '<pd_type>SAD</pd_type>', '<pd_type/>' `
            -replace '<nil/>', '<nil>Y</nil>' `
            -replace 'OldString3', 'NewString3' `
            -replace '22K2', '22T0' `
            -replace '22K1', '22T0' `
            -replace '25K1', '22T0' `
            -replace '45R5', '45R0' `
            -replace 'CNSTG', 'CNNSA' `
            -replace 'CNJUJ', 'CNNGB' `
            -replace 'EEMUG', 'DEHAM' `
            -replace '3402000000', '3402900000' `
            -replace '0000000000', '3924900000' `
            -replace '9817000000', '8703243100' `
            -replace '9995000000', '6911900000' `
            -replace '3038310000', '3004100000' `
            -replace '8430410000', '8703243100' `
            -replace '1993000000', '3302900000' `
            -replace '3924000000', '3924900000' `
            -replace '0712000000', '3402900000' `
            -replace '2208000000', '2208300000' `
            -replace '5407000000', '5407100000' `
            -replace '8450000000', '8450111000' `
            -replace 'OldString1', 'NewString1'

            # If the line was modified, output the original and modified lines
            if ($originalLine -ne $line) {
                Write-Host "File: $($file.FullName)"
                Write-Host "Original: $originalLine"
                Write-Host "Replaced: $line"
                Write-Host ""
            }

            # Add the modified line to the modified content array
            $modifiedContent += $line
        } catch {
            Write-Host "Error processing line in file: $($file.FullName). Error: $_"
        }
    }

    try {
        # Write the modified content back to the file
        $modifiedContent | Set-Content -Encoding ASCII $file.FullName
        Write-Host "Successfully modified file: $($file.FullName)"
    } catch {
        Write-Host "Error writing to file: $($file.FullName). Error: $_"
    }
}

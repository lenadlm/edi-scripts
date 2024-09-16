$files = Get-ChildItem "C:\HLAG\Users\MBELLLE\EDI\EDO\*.xml"

foreach ($file in $files) {
    # Read the original content of the file line by line
    $originalContent = Get-Content $file.FullName

    # Initialize a variable to store the modified content
    $modifiedContent = @()

    foreach ($line in $originalContent) {
        # Store the original line
        $originalLine = $line

        # Apply the replacements to the line
        $line = $line `
        -replace '22K2', '22T0' `
		-replace '25K1', '25T0' `
		-replace '45R5', '45R0' `
		-replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
		-replace 'CNSTG', 'CNNSA' `
        -replace 'CNJUJ', 'CNNGB' `
        -replace 'EEMUG', 'DEHAM' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace '3402000000', '3402900000' `
        -replace '0000000000', '3924900000' `
        -replace '9817000000', '8703243100' `
        -replace '8716800000', '8703243100' `
        -replace '9995000000', '6911900000' `
        -replace '3038310000', '3004100000' `
        -replace '8430410000', '8703243100' `
        -replace '1993000000', '3302900000' `
        -replace '1823000000', '3302900000' `
        -replace '3143000000', '3302900000' `
        -replace '3926901000', '3302900000' `
        -replace '8431390000', '8431100000' `
        -replace '9804000000', '8703243100' `
        -replace '4015110000', '4015190000' `
        -replace '8535000000', '8535100000' `
        -replace '4011000000', '4011100000' `
        -replace '2204000000', '2204100000' `
        -replace '8428900000', '8431100000' `
        -replace '9905000000', '6911900000' `
        -replace '0712000000', '3402900000' `
        -replace '8704211000', '8703243100' `
        -replace '6601000000', '6911900000' `
        -replace '9919100000', '6911900000' `
        -replace '2208000000', '2208300000' `
        -replace '9005000000', '6911900000' `
        -replace '0900000000', '0902300000' `
        -replace '5407000000', '5407100000' `
        -replace '9905000000', '6911900000' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
        -replace 'OldString3', 'NewString3' `
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
    }

    # Write the modified content back to the file
    $modifiedContent | Set-Content -Encoding ASCII $file.FullName
}
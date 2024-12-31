# Define the directory containing the files
$directoryPath = "$PATH"

# Function to apply replacements
function Apply-Replacements {
    param ([string]$line)

    $replacements = @(
        '<pd_type>SAD</pd_type>','<pd_type/>',
        '<nil/>', '<nil>Y</nil>',
        '22K2', '22T0',
        '22K1', '22T0',
        '25K1', '22T0',
        '45R5', '45R0',
        '45S3', '45G1',
        'CNSTG', 'CNNSA',
        'CNJUJ', 'CNNGB',
	    'CNNJI', 'CNNGB',
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
        '5407000000', '5407100000',
        '6907900000', '6904900000',
        '3191430200', '1805000000',
        '3901000000', '3907100000',
        '8703000000', '8708290000',
        '8430500000', '8708290000',
        '3907200000', '3907100000',
        '9919000000', '6911900000',
        '8429511000', '8418100000',
        '8426110000', '8418100000',
        '1210000000', '1210100000',
        '1193000000', '1210100000',
	    '8716391000', '8708290000',
	    '8704311000', '8708290000',
	    '8429520000', '8418100000',
	    '9406000000', '9406101000',
	    '8427100000', '8418100000',
	    '8429519900', '8418100000',
	    '1789000000', '3823190000',
	    '8426410000', '8418100000',
	    '8427200000', '8418100000',
	    '8482000000', '8418100000',
	    '1905000000', '6911900000',
	    '8482900000', '8418100000',
	    '9403000000', '6911900000',
	    '3402190000', '3302900000',
	    '3402190000', '3302900000',
	    '4818400000', '4818500000',
	    '3103000000', '3103110000',
	    '2202000000', '2202910000',
	    '3082000000', '2202910000',
	    '9403900000', '6911900000',
	    '8517700000', '6911900000',
        '1509000000', '1509900000',
        '3808000000', '3808690000',
        '3301000000', '8609000000',
        '3306000000', '8609000000',
        '8708000000', '8708290000',
        '3822000000', '3824999000',
        '8433510000', '8431100000',
        '2811000000', '2811110000',
        '3926000000', '6911900000',
        '9401300000', '6911900000',
        '4825790000', '4802550000',
        '9000000000', '6911900000',
        '8700000000', '8708290000',
        '9018000000', '9018110000',
        'oldstring0', 'newstring0'
    )

    for ($i = 0; $i -lt $replacements.Length; $i += 2) {
        $line = $line -replace $replacements[$i], $replacements[$i + 1]
    }
    return $line
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
        $line = Apply-Replacements -line $line

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

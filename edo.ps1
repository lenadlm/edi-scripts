# Define the directory containing the files
$directoryPath = "C:\HLAG\Users\MBELLLE\EDI\EDO"

# Define a set of characters to randomly choose from
$characters = "0123456789".ToCharArray()

# Function to get a random character from the set
function Get-RandomCharacter {
    return $characters | Get-Random
}

# Initialize variables
$oldChar = ""
$newChar = ""

# Get random characters for replacement
do {
    $oldChar = Get-RandomCharacter
    $newChar = Get-RandomCharacter
} while ($oldChar -eq $newChar)

Write-Host "Replacing '$oldChar' with '$newChar' in filenames"

# Get all .txt files in the directory
$files = Get-ChildItem "$directoryPath\*.txt"

foreach ($file in $files) {
    # Replace specific strings in the file content
    $content = Get-Content $file.FullName
    $content = $content `
        -replace 'OldString', 'NewString' `
        -replace '2431S ', '02431N' `
        -replace '02SHXS1MA', '02SHYN1MA' `
        -replace '02SGPS1MA', '02SGQN1MA' `
        -replace ' 431W     ', ' KKRM0431W' `
        -replace '02SHRS1MA', '02SHSN1MA' `
        -replace '02SHZS1MA', '02SI0N1MA' `
        -replace ' 432W     ', ' KLMB0432W' `
        -replace '02SIHS1MA', '02SIIN1MA' `
        -replace ' 433W     ', ' KKAY0433W' `
        -replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
		-replace 'OldString3', 'NewString3' `
        -replace 'OldString2', 'NewString2' `
		-replace 'OldString3', 'NewString3' `
        -replace 'OldString3', 'NewString3'

    # Write the modified content back to the file
    $content | Set-Content -Encoding ASCII $file.FullName

    # Check if the filename contains the old character
    if ($file.Name -like "*$oldChar*") {
        # Create the new filename by replacing the old character with the new one
        $newFileName = $file.Name -replace $oldChar, $newChar

        # Rename the file
        Rename-Item -Path $file.FullName -NewName $newFileName
        
        Write-Host "Renamed '$($file.Name)' to '$newFileName'"
    }
}

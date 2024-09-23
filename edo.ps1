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

# Array of string replacements in the format: OldString -> NewString
$replacements = @(
    @('OldString', 'NewString'),
    @('2431S ', '02431N'),
    @('02SHXS1MA', '02SHYN1MA'),
    @('02SGPS1MA', '02SGQN1MA'),
    @(' 431W     ', ' KKRM0431W'),
    @('02SHRS1MA', '02SHSN1MA'),
    @('02SHZS1MA', '02SI0N1MA'),
    @(' 432W     ', ' KLMB0432W'),
    @('02SIHS1MA', '02SIIN1MA'),
    @(' 433W     ', ' KKAY0433W'),
    @('02SSIS1MA', '02STGN1MA'),
    @(' 435W     ', ' KKMI0435W'),
    @('OldString3', 'NewString3')
)

# Get all .txt files in the directory
$files = Get-ChildItem "$directoryPath\*.txt"

foreach ($file in $files) {
    # Get file content
    $content = Get-Content $file.FullName
    
    # Apply each replacement
    foreach ($replacement in $replacements) {
        $content = $content -replace $replacement[0], $replacement[1]
    }
    
    # Write the modified content back to the file
    $content | Set-Content -Encoding UTF8 $file.FullName

    # Check if the filename contains the old character
    if ($file.Name -like "*$oldChar*") {
        # Create the new filename by replacing the old character with the new one
        $newFileName = $file.Name -replace $oldChar, $newChar

        # Rename the file with error handling
        try {
            Rename-Item -Path $file.FullName -NewName $newFileName
            Write-Host "Renamed '$($file.Name)' to '$newFileName'"
        } catch {
            Write-Host "Failed to rename '$($file.Name)': $_"
        }
    }
}

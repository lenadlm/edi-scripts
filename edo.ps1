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
    @('2444S ', '02444N'),
    @('2448S ', '02448N'),
    @(' 433W     ', ' KKAY0433W'),
    @(' 435W     ', ' KKMI0435W'),
    @(' 438W     ', ' KKRM0438W'),
    @(' 441W     ', ' KGDG0441W'),
    @(' 443W     ', ' KSJI0443W'),
    @(' 446W     ', ' KLMB0446W'),
    @(' 447W     ', ' KSMP0447W'),
    @('02SIXS1MA', '02SIYN1MA'),
    @('02SIHS1MA', '02SIIN1MA'),
    @('02SIRS1MA', '02SISN1MA'),
    @('02SINS1MA', '02STPN1MA'),
    @('02SILS1MA', '02SIMN1MA'),
    @('02SJ1S1MA', '02SJ2N1MA'),
    @('02SJ7S1MA', '02SJ8N1MA'),
    @('444W', '444E'),
    @('V7A4476', '3E6877 '),
    @('OldString3', 'NewString3')
)

# Get all .txt files in the directory
$files = Get-ChildItem -Path "$directoryPath\*.txt" -Force

foreach ($file in $files) {
    try {
        # --- Step 1: Update File Content ---
        $content = Get-Content $file.FullName
        
        foreach ($replacement in $replacements) {
            $content = $content -replace $replacement[0], $replacement[1]
        }

        # Save updated content
        $content | Set-Content -Encoding UTF8 $file.FullName

        # --- Step 2: Rename the File ---
        # Ensure old character replacement happens every time
        $newFileName = $file.Name -replace [regex]::Escape($oldChar), $newChar

        if ($file.Name -ne $newFileName) {
            Rename-Item -Path $file.FullName -NewName $newFileName
            Write-Host "Renamed: '$($file.Name)' to '$newFileName'"
        } else {
            Write-Host "Not renamed: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing file '$($file.FullName)': $_"
    }
}

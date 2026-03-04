# === CONFIGURATION ===
$BasePath = "C:\Users\...\Documents\Amendments"
$SkipNames = @("Archive")
$Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$ZippedFolderName = "Zipped_$Timestamp"
$ZippedPath = Join-Path $BasePath $ZippedFolderName
$ArchivePath = Join-Path $BasePath "Archive"
$MaxZipNameLength = 100

Add-Type -AssemblyName System.IO.Compression.FileSystem

function SafeName($name, $max) {
    if ($name.Length -le $max) { return $name }
    return $name.Substring(0, $max)
}

function Should-Skip($name) {
    if ($SkipNames -contains $name) { return $true }
    if ($name -like "Zipped_*") { return $true }
    return $false
}

# Create necessary folders
if (-not (Test-Path $ZippedPath)) { New-Item -ItemType Directory $ZippedPath | Out-Null }
if (-not (Test-Path $ArchivePath)) { New-Item -ItemType Directory $ArchivePath | Out-Null }

Set-Location $BasePath

# --- ZIP DIRECTORIES ---
Get-ChildItem -Directory | Where-Object {
    -not (Should-Skip $_.Name) -and $_.Name -ne $ZippedFolderName
} | ForEach-Object {

    $dir = $_
    $safe = SafeName $dir.Name $MaxZipNameLength
    $zipTarget = Join-Path $ArchivePath ("$safe.zip")

    Write-Host "Zipping folder: $($dir.Name)"

    try {

        # ✅ OVERWRITE FIX
        if (Test-Path $zipTarget) {
            Write-Host "ZIP already exists — overwriting..."
            Remove-Item $zipTarget -Force
        }

        [System.IO.Compression.ZipFile]::CreateFromDirectory($dir.FullName, $zipTarget)
        Write-Host "Created ZIP → $zipTarget"

        Move-Item $dir.FullName $ZippedPath -Force
        Write-Host "Moved original → $ZippedPath"
    }
    catch {
        Write-Host "ERROR zipping folder $($dir.Name): $_"
    }
}

# --- ZIP FILES ---
Get-ChildItem -File | Where-Object {
    $_.Extension -ne ".zip" -and -not (Should-Skip $_.Name)
} | ForEach-Object {

    $file = $_
    $safe = SafeName $file.BaseName $MaxZipNameLength
    $zipTarget = Join-Path $ArchivePath ("$safe.zip")

    Write-Host "Zipping file: $($file.Name)"

    try {

        # ✅ OVERWRITE FIX
        if (Test-Path $zipTarget) {
            Write-Host "ZIP already exists — overwriting..."
            Remove-Item $zipTarget -Force
        }

        $temp = Join-Path $env:TEMP ([GUID]::NewGuid().ToString())
        New-Item -ItemType Directory $temp | Out-Null
        Copy-Item $file.FullName -Destination $temp -Force

        [System.IO.Compression.ZipFile]::CreateFromDirectory($temp, $zipTarget)
        Remove-Item $temp -Recurse -Force
        
        Write-Host "Created ZIP → $zipTarget"

        Move-Item $file.FullName $ZippedPath -Force
        Write-Host "Moved original → $ZippedPath"
    }
    catch {
        Write-Host "ERROR zipping file $($file.Name): $_"
    }
}

Write-Host "-------------------------------------------------"
Write-Host "Completed. All ZIP files in Archive. Originals in $ZippedFolderName."

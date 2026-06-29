$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
$env:Path = "D:\ProgramData\MSYS2\ucrt64\bin;D:\ProgramData\MSYS2\usr\bin;$env:Path"

$siteDir = Join-Path $root "_site"
$zipPath = Join-Path $root "portfolio-offline.zip"
$offlineEntry = ([string][char]0x4F5C + [char]0x54C1 + [char]0x96C6 + ".html")

Write-Host "Cleaning previous build..."
if (Test-Path -LiteralPath $siteDir) {
  try {
    Remove-Item -LiteralPath $siteDir -Recurse -Force
  } catch {
    Write-Error "Failed to remove _site. Close any browser, preview server, or file explorer window using _site, then run this script again."
    exit 1
  }
}
Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue

Write-Host "Building site..."
& "D:\ProgramData\MSYS2\ucrt64\bin\bundle.bat" exec jekyll build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Get-ChildItem -LiteralPath $siteDir -File -Force |
  Where-Object { $_.Name -in @("README.md", "package-offline.ps1", "package-offline.bat", "serve-local.bat") } |
  Remove-Item -Force

Write-Host "Creating portfolio-offline.zip..."
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  $files = Get-ChildItem -LiteralPath $siteDir -Recurse -File
  foreach ($file in $files) {
    $relative = $file.FullName.Substring($siteDir.Length + 1)
    $entryName = $relative.Replace("\", "/")

    if ($entryName -eq "README.md") { continue }
    if ($entryName -eq "index.html") { $entryName = $offlineEntry }
    if ($entryName -eq "assets/css/style.css") { continue }
    if ($entryName -like "assets/fonts/*") { continue }
    if ($entryName -like "assets/img/*") { continue }
    if ($entryName -eq "assets/js/scale.fix.js") { continue }

    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
      $zip,
      $file.FullName,
      $entryName,
      [System.IO.Compression.CompressionLevel]::Optimal
    ) | Out-Null
  }
} finally {
  $zip.Dispose()
}

$zipItem = Get-Item -LiteralPath $zipPath
Write-Host ("Done: {0:N2} MB" -f ($zipItem.Length / 1MB))
Write-Host ("Open {0} after extracting the zip." -f $offlineEntry)

Get-ChildItem -LiteralPath $siteDir -File -Force |
  Where-Object { $_.Name -in @("README.md", "package-offline.ps1", "package-offline.bat", "serve-local.bat") } |
  Remove-Item -Force

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $projectRoot 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$outputDirectory = Join-Path $projectRoot 'dist'
$packagePath = Join-Path $outputDirectory "reddit-anon-view-$($manifest.version)-unsigned.xpi"

if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$packageStream = [System.IO.File]::Open($packagePath, [System.IO.FileMode]::Create)
try {
    $archive = [System.IO.Compression.ZipArchive]::new(
        $packageStream, [System.IO.Compression.ZipArchiveMode]::Create, $true
    )
    try {
        # Explicit runtime-only list keeps documentation and development files out.
        foreach ($runtimeFile in @('manifest.json', 'content.js')) {
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $archive, (Join-Path $projectRoot $runtimeFile), $runtimeFile
            ) | Out-Null
        }
    }
    finally {
        $archive.Dispose()
    }
}
finally {
    $packageStream.Dispose()
}

Write-Output "Unsigned Firefox package: $packagePath"
Write-Output 'Submit it for Mozilla signing before persistent installation in normal Firefox.'

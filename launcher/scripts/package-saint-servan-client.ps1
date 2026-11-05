# Build a separate portable client by replacing only the Tauri launcher binary.
# Preserve the original simulator executable, DLLs, licenses and notices.
param(
    [Parameter(Mandatory = $true)] [string]$OriginalDistribution,
    [Parameter(Mandatory = $true)] [string]$CompiledLauncher,
    [Parameter(Mandatory = $true)] [string]$Destination,
    [string]$Version = '0.3.45'
)
$ErrorActionPreference = 'Stop'
$original = (Resolve-Path -LiteralPath $OriginalDistribution).Path.TrimEnd('\')
$launcher = (Resolve-Path -LiteralPath $CompiledLauncher).Path
$target = [IO.Path]::GetFullPath($Destination).TrimEnd('\')

foreach ($name in @('openomsi.exe', 'openomsi-launcher-app.exe', 'LICENSE')) {
    if (-not (Test-Path -LiteralPath (Join-Path $original $name))) {
        throw "Original distribution is missing $name."
    }
}
if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
    throw "Custom launcher executable missing: $launcher"
}
if ($target.Equals($original, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Destination must differ from the original distribution.'
}
if ($target.StartsWith("$original\", [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Destination must not be nested inside the original distribution.'
}
New-Item -ItemType Directory -Force -Path $target | Out-Null

# Preserve every upstream file; do not delete content or strip attribution.
& robocopy.exe $original $target /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NP /MT:4 /NFL /NDL
$copyExit = $LASTEXITCODE
if ($copyExit -ge 8) { throw "Could not copy original distribution (Robocopy exit $copyExit)." }

$destinationLauncher = Join-Path $target 'openomsi-launcher-app.exe'
Copy-Item -LiteralPath $launcher -Destination $destinationLauncher -Force
$sourceHash = (Get-FileHash -LiteralPath $launcher -Algorithm SHA256).Hash
$targetHash = (Get-FileHash -LiteralPath $destinationLauncher -Algorithm SHA256).Hash
if ($sourceHash -ne $targetHash) { throw 'Custom launcher hash mismatch.' }

$notes = @"
# Saint-Servan openOMSI launcher $Version
Custom Tauri interface based on the Saint-Servan website design.
- Executable: openomsi-launcher-app.exe
- Original game binary, DLLs, LICENSE and notices: preserved.
- Source fork: https://github.com/Mesrine67/openOMSI
- The complete OMSI 2 installation is not redistributed.
- Launcher SHA-256: $targetHash
"@
[IO.File]::WriteAllText((Join-Path $target 'SAINT-SERVAN-NOTES.md'), $notes, [Text.UTF8Encoding]::new($false))
Write-Host "Custom client ready: $target"
Write-Host "Launcher SHA-256: $targetHash"
exit 0

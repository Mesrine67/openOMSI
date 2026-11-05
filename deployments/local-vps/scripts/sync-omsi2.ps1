# Copy OMSI 2 assets from a legally installed Steam copy, without changing it.
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [string]$Source = 'C:\Program Files (x86)\Steam\steamapps\common\OMSI 2'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $Source 'Omsi.exe'))) {
    throw "OMSI 2 was not found at: $Source"
}
$src = (Resolve-Path -LiteralPath $Source).Path.TrimEnd('\')
$dst = [IO.Path]::GetFullPath($Destination).TrimEnd('\')
if ($src.Equals($dst, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Source and destination cannot be the same.'
}
if ($dst.StartsWith("$src\", [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The destination must not be nested within the game installation.'
}
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# Deliberately no /MIR or /PURGE: never delete the original or copied mods.
& robocopy.exe $src $dst /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /MT:8
$code = $LASTEXITCODE
if ($code -ge 8) { throw "OMSI 2 copy failed (robocopy exit $code)." }
Write-Host "OMSI 2 assets synchronized to $dst (robocopy exit $code)."

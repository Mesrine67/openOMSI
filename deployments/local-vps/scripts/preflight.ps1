# Read-only checks for the portable Docker deployment. Does NOT start Docker or WSL.
param(
    [string]$ComposeDirectory = (Join-Path $PSScriptRoot '..'),
    [string]$OmsiDirectory
)
$ErrorActionPreference = 'Stop'
$dir = [IO.Path]::GetFullPath($ComposeDirectory)
$compose = Join-Path $dir 'compose.yaml'
if (-not (Test-Path -LiteralPath $compose)) { throw "Missing Docker Compose file: $compose" }
Write-Host "Compose directory: $dir"
if (-not $OmsiDirectory) {
    $envPath = Join-Path $dir '.env'
    if (Test-Path -LiteralPath $envPath) {
        $setting = Get-Content -LiteralPath $envPath | Where-Object { $_ -match '^\s*OMSI_DIR\s*=' } | Select-Object -Last 1
        if ($setting) {
            $OmsiDirectory = ($setting -split '=', 2)[1].Trim().Trim('"').Trim("'")
        }
    }
}
if ($OmsiDirectory) {
    Write-Host "Original OMSI content exists: $(Test-Path -LiteralPath (Join-Path $OmsiDirectory 'Omsi.exe'))"
    Write-Host 'Installed maps:'
    Get-ChildItem -LiteralPath (Join-Path $OmsiDirectory 'maps') -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
} else {
    Write-Warning 'No OMSI_DIR provided or found in .env.'
}
Write-Host "Prebuilt Linux server exists: $(Test-Path -LiteralPath (Join-Path $dir 'bin\openomsi'))"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning 'Docker CLI unavailable: Compose not validated.'
    exit 0
}
& docker compose --project-directory $dir -f $compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose configuration is invalid.' }
Write-Host 'Compose configuration: valid.'
try { & docker info --format 'Linux engine: {{.ServerVersion}}' 2>$null } catch {}
Write-Host 'Preflight complete. No service started or stopped.'

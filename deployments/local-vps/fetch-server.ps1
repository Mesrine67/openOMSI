param([string]$Version = '0.3.45')
$ErrorActionPreference = 'Stop'
$asset = "openOMSI-$Version-server-linux-x64.zip"
$base = "https://github.com/openOMSI-org/openOMSI/releases/download/v$Version"
New-Item -ItemType Directory -Force 'downloads','bin' | Out-Null
Invoke-WebRequest "$base/$asset" -OutFile "downloads/$asset"
Invoke-WebRequest "$base/SHA256SUMS" -OutFile 'downloads/SHA256SUMS'
$line = Get-Content 'downloads/SHA256SUMS' | Where-Object { $_ -match [regex]::Escape($asset) }
$expected = ($line -split '\s+')[0].ToLowerInvariant()
$actual = (Get-FileHash "downloads/$asset" -Algorithm SHA256).Hash.ToLowerInvariant()
if ($expected -ne $actual) { throw "SHA256 mismatch: $asset" }
Expand-Archive -Path "downloads/$asset" -DestinationPath 'bin' -Force
Write-Host "Downloaded and verified openOMSI $Version Linux x64 server"

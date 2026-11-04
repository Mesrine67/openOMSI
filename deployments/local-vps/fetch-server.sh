#!/usr/bin/env bash
set -euo pipefail
VERSION="${OPENOMSI_VERSION:-0.3.45}"
ARCH="openOMSI-${VERSION}-server-linux-x64.zip"
BASE="https://github.com/openOMSI-org/openOMSI/releases/download/v${VERSION}"
command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v unzip >/dev/null || { echo 'unzip is required' >&2; exit 1; }
command -v sha256sum >/dev/null || { echo 'sha256sum is required' >&2; exit 1; }
mkdir -p downloads bin
curl -fL --retry 3 -o "downloads/${ARCH}" "${BASE}/${ARCH}"
curl -fL --retry 3 -o downloads/SHA256SUMS "${BASE}/SHA256SUMS"
(
  cd downloads
  grep "  ${ARCH}$" SHA256SUMS | sha256sum --check --status
) || { echo "Checksum validation failed for ${ARCH}" >&2; exit 2; }
unzip -o "downloads/${ARCH}" -d bin >/dev/null
chmod +x bin/openomsi
printf 'Verified and extracted openOMSI %s Linux x64 server in bin/\n' "${VERSION}"

#!/usr/bin/env bash
# Optional convenience shortcuts for a dedicated WSL2 distribution.
# This does NOT install the actual server in the distro; Docker Desktop owns it.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Usage: sudo bash %s /mnt/e/Projects/openOMSI-Lab/deploy\n' "$0" >&2
  exit 2
fi
if [[ "$(id -u)" != "0" ]]; then
  echo 'Run as root inside a dedicated openOMSI WSL distribution.' >&2
  exit 1
fi
compose_dir="$1"
if [[ ! -f "$compose_dir/compose.yaml" ]]; then
  echo "Compose file missing: $compose_dir/compose.yaml" >&2
  exit 1
fi
if ! id omsi >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash omsi
fi
install -d -o omsi -g omsi /home/omsi
ln -sfn -- "$compose_dir" /home/omsi/openomsi-deploy
chown -h omsi:omsi /home/omsi/openomsi-deploy

# Keep existing WSL config when present; do not reset other distributions.
if ! grep -q '^\[user\]' /etc/wsl.conf 2>/dev/null; then
  printf '\n[user]\ndefault=omsi\n' >> /etc/wsl.conf
fi

# Quote the selected Linux path and preserve arguments for Compose.
printf -v quoted_dir '%q' "$compose_dir"
cat > /usr/local/bin/openomsi-compose <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd $quoted_dir
exec docker compose "\$@"
EOF
chmod 0755 /usr/local/bin/openomsi-compose
cat > /usr/local/bin/openomsi-status <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
curl -fsS http://127.0.0.1:27025/status
EOF
chmod 0755 /usr/local/bin/openomsi-status
echo 'openOMSI Compose shortcuts are ready. Your Docker engine must be started separately.'

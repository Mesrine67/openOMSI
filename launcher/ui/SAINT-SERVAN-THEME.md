# Saint-Servan launcher theme

This opt-in look is used by the `Mesrine67/openOMSI` fork to match the
Saint-Servan site from `D:\gpm-next-modern\gpm-next-modern`.

## Source of truth

The palette, rounded corners and motion tokens were mapped from the site's
`app/globals.css` (November 4, 2026). The icon is copied from
`public/brand/saint-servan.svg`.

The stylesheet `launcher/ui/saint-servan-theme.css` is loaded **after**
the stock `launcher/ui/styles.css`. Its selectors are gated by
`data-brand="saint-servan"`; remove that attribute in `index.html`
to restore upstream openOMSI styling, without removing the stylesheet.
The launcher still obeys `data-theme="light"` or `"dark"`
and the existing settings UI; the game, dedicated server, network commands,
and asset formats are not changed.

The main sidebar displays openOMSI as the product name and Saint-Servan as
the community theme label.

## Development and checks

```powershell
node --experimental-vm-modules --test launcher/tests/theme-startup.test.mjs
node --test launcher/tests/saint-servan-theme.test.mjs
node --check launcher/ui/js/app.js
$env:CHROME = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$env:DRIVE_CHECK_SIZES = "1280x720,1920x1080"
node launcher/tests/drive-check.mjs
```

## Executable

This is **source code**, not a change to an already distributed executable.
openOMSI bundles its webview resources inside `openomsi-launcher-app.exe`.
To test the themed Tauri app, build the launcher from this branch:

```powershell
$env:CARGO_TARGET_DIR = "E:\Projects\openOMSI-Lab\build\saint-servan"
cargo build --release --manifest-path launcher/src-tauri/Cargo.toml
```

Avoid replacing the existing stable executable until a matching launcher
build and game version have passed their integration tests.
Do not commit the original OMSI 2 installation or DLC content to GitHub.

## Packaging a separate portable Saint-Servan client

Use launcher/scripts/package-saint-servan-client.ps1 with the arguments
-OriginalDistribution, -CompiledLauncher, -Destination and -Version.
The script copies every original executable, DLL and LICENSE/NOTICE into a
separate directory, then replaces only the Tauri launcher with the custom
compiled executable and verifies its SHA-256 hash. Never commit OMSI 2 game
assets, binaries, DLC, local logs, Docker data or credentials.

For the v0.3.45 compatibility branch, set the build environment variable
OPENOMSI_VERSION=0.3.45 before cargo build --release; otherwise the version
logic automatically increments the number on untagged branches.

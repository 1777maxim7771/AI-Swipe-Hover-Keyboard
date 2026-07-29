# Changelog

## Installer hotfix — 2026-07-29

- Fixed `latest.json does not contain package_parts` in old local installers.
- The BAT now downloads the newest PowerShell installer before checking the manifest.
- The PowerShell installer accepts `download_url`, `package_url`, and legacy `package_parts`.
- Added cache-busting, retry logic, expected/actual SHA-256 logging, configuration preservation, and rollback protection.
- The application package remains version 4.3.1; this entry updates the installation mechanism.

## 4.3.1 — 2026-07-29

- Published a direct GitHub ZIP package with SHA-256 verification.
- Updater now prefers `download_url`; multipart download remains a compatibility fallback inside the package.
- Preserves local API key, settings, window position, learning data, language statistics, and logs.

## 4.3.0 — 2026-07-29

- Added GitHub update check before launch.
- Added custom title bar with minimize, maximize/restore, and close controls.
- Removed upper glossy shade from circular keys.
- Kept fixed ring coordinates and slot-for-slot content swapping.

## 4.2.0

- Added two fixed concentric rings, local T9 highlighting, and full-height word suggestions.

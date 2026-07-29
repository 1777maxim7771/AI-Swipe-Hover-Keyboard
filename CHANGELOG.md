# Changelog

## Package integrity fix — 2026-07-29 (evening)

- The direct ZIP published for release 16 was corrupted (only ~15 KB, missing valid ZIP central directory).
- This caused `Expand-Archive` / `.ctor` error: "Не удается найти конец записи центрального каталога".
- Temporarily restored a working package by pointing `latest.json` to the known-good `package_parts` of release 15.
- Installer already supports the multipart Base64 fallback path, so installation works again.
- A clean direct ZIP for 4.3.1 will be republished later.

## SHA-256 correction — 2026-07-29

- Corrected the `sha256` value in `latest.json` for release 16.
- Previous hash did not match the actual content of the (later discovered corrupted) ZIP.

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

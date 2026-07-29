# Changelog

## 4.3.2 installer path hotfix — 2026-07-29 23:27

- Fixed installer failure after clean-source SHA-256 verification.
- Root cause: `python -m py_compile` attempted to create a temporary `.pyc` file inside a path longer than the classic Windows MAX_PATH limit.
- The failing path was about 275 characters long and ended in `PROGRAM_FILES\__pycache__\vertical_predictive_letter_wheel.cpython-314.pyc.<temporary-id>`.
- The installer now uses a short temporary directory such as `%TEMP%\ASHK_ab12cd34`.
- Python syntax is validated in memory with `compile(...)`, so no `__pycache__` or `.pyc` files are created.
- All Python source files are validated, not only the repaired main module.
- Stale `__pycache__` directories and `.pyc` files are removed before installation.

## 4.3.2 — 2026-07-29

- Fixed startup failure `SyntaxError: unterminated string literal` in `vertical_predictive_letter_wheel.py` at line 1419.
- Root cause: the legacy reconstructed package contained a damaged/truncated Python source file even though the package-level SHA matched the published legacy package.
- Added a separate clean-source repair payload split into four verified Base64/GZip parts.
- Installer now restores the complete Python source after package extraction.
- The restored source is checked with its own SHA-256 value and then syntax-validated before any program files are installed.
- Updater now compares both application version and main-source SHA-256; it repairs a damaged installation even when version numbers appear current.
- Added root `UPDATE_FROM_GITHUB.ps1` and `UPDATE_AND_START.bat` so installed copies always fetch the current repair logic.

## Package integrity fix — 2026-07-29 (evening)

- The direct ZIP published for release 16 was corrupted (only ~15 KB, missing valid ZIP central directory).
- This caused `Expand-Archive` / `.ctor` error: "Не удается найти конец записи центрального каталога".
- Temporarily restored a working package by pointing `latest.json` to the known-good `package_parts` of release 15.
- Installer already supports the multipart Base64 fallback path, so installation works again.

## SHA-256 correction — 2026-07-29

- Corrected the `sha256` value in `latest.json` for release 16.
- Previous hash did not match the actual content of the later-discovered corrupted ZIP.

## Installer hotfix — 2026-07-29

- Fixed `latest.json does not contain package_parts` in old local installers.
- The BAT now downloads the newest PowerShell installer before checking the manifest.
- The PowerShell installer accepts `download_url`, `package_url`, and legacy `package_parts`.
- Added cache-busting, retry logic, expected/actual SHA-256 logging, configuration preservation, and rollback protection.

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

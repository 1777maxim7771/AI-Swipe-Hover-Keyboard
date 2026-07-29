# Repository workflow

- `latest.json` points to the current stable version and its package parts.
- `versions/<version-name>/` contains immutable Base64 package parts and a manifest.
- `INSTALL_LATEST_FROM_GITHUB.bat` performs the first installation.
- After installation, run `UPDATE_AND_START.bat` from the application directory.
- Every update verifies the SHA-256 hash before extraction.
- Local API keys, settings, learning data, window position, language statistics, and logs are preserved.
- Git commit history and `CHANGELOG.md` are used to avoid repeating completed work.

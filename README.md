# AI Swipe Hover Keyboard

Current stable application version: **4.3.1**.

## First installation

Download the repository and run:

```bat
INSTALL_LATEST_FROM_GITHUB.bat
```

The BAT now downloads the newest installer logic from GitHub before reading `latest.json`. This prevents an old local PowerShell installer from failing when the manifest format changes.

The installer supports all known package fields:

- `download_url` — current direct ZIP format;
- `package_url` — previous direct ZIP alias;
- `package_parts` — legacy multipart Base64 format.

Installation and update logs are written to `INSTALL_LOG.txt` and `UPDATE_LOG.txt`.

## Normal start with update check

After installation, start the program through:

```bat
UPDATE_AND_START.bat
```

The updater checks `latest.json` on GitHub before every start. When a newer version exists, it downloads the ZIP, verifies SHA-256, preserves the local API key and user data, installs the update, and starts the program. When GitHub is unavailable, the currently installed version starts.

## Current interface

- Two fixed concentric rings.
- Mouse wheel swaps ring contents slot-for-slot without moving button positions.
- Local T9 highlighting and full-height word suggestions.
- Custom title bar with minimize, maximize/restore, and close controls.
- Upper glossy shade removed from circular keys.

## Development history

Git commits are the canonical history. Before each change, review all commits since the last known SHA and compare changed files to avoid duplicating completed work.

## Security

Never commit a real OpenAI API key. The repository and packages contain only a placeholder.

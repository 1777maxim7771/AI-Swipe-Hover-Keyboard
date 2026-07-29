# AI Swipe Hover Keyboard

Current stable version: **4.3.1**.

## First installation

Download the repository and run:

```bat
INSTALL_LATEST_FROM_GITHUB.bat
```

## Normal start with update check

After installation, start the program through:

```bat
UPDATE_AND_START.bat
```

The BAT checks `latest.json` on GitHub before every start. When a newer version exists, the updater downloads the ZIP, verifies SHA-256, preserves the local API key and user data, installs the update, and starts the program. When GitHub is unavailable, the currently installed version starts.

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

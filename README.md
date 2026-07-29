# AI Swipe Hover Keyboard

Floating Windows hover keyboard with two fixed concentric rings, local T9 highlighting,
word suggestions, OpenAI-assisted correction, and automatic updates from this repository.

## First installation

Download or clone this repository and run:

```bat
INSTALL_LATEST_FROM_GITHUB.bat
```

The installer reconstructs the latest verified version package and starts it.

## Start with automatic update

Run:

```bat
UPDATE_AND_START.bat
```

The updater checks `main` on GitHub, compares `VERSION_INFO.txt`, reads `latest.json`, reconstructs the published version ZIP from GitHub package parts
when available, preserves local configuration and the local API key file, and then starts the app.
If the network is unavailable, the currently installed version is started.

## Normal start

- `PROGRAM_FILES/START_WITH_CONSOLE.bat` — console and logs.
- `PROGRAM_FILES/START_NO_CONSOLE.bat` — no console.

## Security

The repository contains only an API-key placeholder. Never commit a real API key.

## Current version

**4.3.0**

## Interface changes in 4.3.0

- Custom title bar with minimize, maximize/restore, and close controls.
- Native operating-system title frame removed.
- Upper glossy shade removed from circular keys.
- Fixed inner/outer ring slots and slot-for-slot content swapping remain unchanged.
- Added GitHub self-update BAT and PowerShell updater.

## Published package

The current stable package is described by `latest.json` and stored under `versions/` as verified Base64 parts.

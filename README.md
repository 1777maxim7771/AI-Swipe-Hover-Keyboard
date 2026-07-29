# AI Swipe Hover Keyboard

Current stable application version: **4.3.2**.

## First installation or repair

Download the repository and run:

```bat
INSTALL_LATEST_FROM_GITHUB.bat
```

The BAT first downloads the newest installer logic from GitHub. The installer then:

1. reads `latest.json`;
2. downloads and verifies the published package;
3. restores the complete clean `vertical_predictive_letter_wheel.py` from a separately verified repair payload;
4. verifies the restored source SHA-256;
5. runs `python -m py_compile` before copying files into the installation directory;
6. preserves the local API key, settings, window position, learning data, language statistics, and logs;
7. installs the current updater and starts the application.

The installer supports all known package fields:

- `download_url` — direct ZIP;
- `package_url` — previous direct ZIP alias;
- `package_parts` — multipart Base64 package;
- `repair_source_parts` — separately verified clean-source recovery payload.

Installation and update logs are written to `INSTALL_LOG.txt` and `UPDATE_LOG.txt`.

## Normal start with update and integrity check

After installation, start the program through:

```bat
UPDATE_AND_START.bat
```

The updater checks both the version and the SHA-256 of the main Python source. A source repair is triggered even when the version number appears current but the installed source is damaged.

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

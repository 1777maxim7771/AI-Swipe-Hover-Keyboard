# BUG-003 — Unterminated string literal at line 1419

Date: 2026-07-29
Status: Fixed in installer/updater 4.3.2; awaiting user verification on Windows.

## Symptom

The package installed successfully, but startup failed with:

```text
SyntaxError: unterminated string literal (detected at line 1419)
vertical_predictive_letter_wheel.py, line 1419
LOG.info("Letter selectede
```

## Root cause

The fallback package reconstructed from the legacy multipart release passed the package-level SHA that had been published for that exact legacy artifact, but the Python source inside that artifact was damaged/truncated. Therefore ZIP verification alone could not prove that the application source was syntactically valid.

## Fix

- Added a separate clean-source recovery payload under `repairs/v4.3.2/`.
- The clean source is compressed with GZip, encoded as Base64, and split into four repository files.
- `latest.json` publishes the repair-part URLs and the expected SHA-256 of the complete Python source.
- The installer restores the source after ZIP extraction.
- The installer verifies the restored file SHA-256.
- The installer runs `python -m py_compile` before changing the installed application.
- The updater compares the installed source hash with the manifest and repairs it even if the version number is already current.

## Regression rule

A release is not considered installable until all Python files pass `py_compile` after the exact published download/reconstruction path, not only before packaging.

Expected main-source SHA-256 for 4.3.2:

```text
0f0a1b1f253911bef920ba7f05a8b7a55292b0a8409a40668695fe8ec2f7b88c
```

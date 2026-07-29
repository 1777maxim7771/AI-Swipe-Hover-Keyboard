# BUG-004 — Windows MAX_PATH failure during `py_compile` validation

**Date:** 2026-07-29 23:27 +02:00  
**Status:** Fixed in installer hotfix  
**Component:** `INSTALL_LATEST_FROM_GITHUB.ps1`

## Symptom

The package and clean-source SHA-256 checks both passed, but installation stopped with:

```text
[Errno 2] No such file or directory: ...\PROGRAM_FILES\__pycache__\vertical_predictive_letter_wheel.cpython-314.pyc.<temporary-id>
INSTALL ERROR: Repaired Python source failed py_compile validation.
```

## Root cause

The clean source was valid. `python -m py_compile` tried to create an atomic temporary `.pyc` file under `__pycache__` inside a deeply nested extraction path. The effective path was approximately 275 characters long, exceeding the classic Windows MAX_PATH limit of 260 characters for this operation. Windows reported the failure as `Errno 2` even though the source file itself existed.

## Fix

- Shortened the temporary root to `%TEMP%\ASHK_<8-character-id>`.
- Replaced `python -m py_compile` with in-memory syntax validation using Python `compile(...)`.
- Validate every `*.py` file in the extracted package.
- Remove stale `__pycache__` directories and `.pyc` files before installation.
- Keep SHA-256 validation, configuration preservation, and rollback behavior unchanged.

## Regression requirements

1. Test installation from a long Windows user path.
2. Test with long release-folder names.
3. Confirm no `__pycache__` or `.pyc` is created during pre-install validation.
4. Confirm all Python files pass in-memory syntax validation.
5. Confirm the existing installation is not modified when validation fails.

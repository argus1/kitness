# Data Rehydration Guide

This repository tracks only lightweight placeholders for large sequencing assets.

- `Data/BB/PLACEHOLDERS.json` → BaiBai (BB)
- `Data/HH/PLACEHOLDERS.json` → HuaHua (HH)

The actual files are hosted in Google Drive and should be downloaded locally when needed.

## Why this exists

Sequencing data is too large for normal git hosting and impractical for this repo remote even with LFS. We preserve:

- exact expected filenames
- dataset aliases
- source folder IDs/URLs

This keeps the analysis workflow reproducible while avoiding oversized commits.

## Prerequisites

1. Access to the BB and HH Google Drive folders.
2. Sufficient local disk space for downloaded data.
3. Python 3.9+.
4. `gdown` installed in your active environment.

## Rehydrate data

From the repository root:

1. Check what is currently present:
   - `python scripts/prepare_data.py status`
2. Download one dataset:
   - `python scripts/prepare_data.py download BB`
   - `python scripts/prepare_data.py download HH`
3. Download both datasets:
   - `python scripts/prepare_data.py download all`
4. Re-check status:
   - `python scripts/prepare_data.py status`

Expected target paths:

- `Data/BB`
- `Data/HH`

## Notes

- If status reports missing files after download, verify Drive sharing permissions first.
- If files already exist and you want to force a fresh pass, use:
  - `python scripts/prepare_data.py download all --force`
- Downloaded large files under `Data/BB` and `Data/HH` are ignored by git (manifests remain tracked).

#!/usr/bin/env python3
"""Rehydrate large sequencing datasets from Google Drive folder placeholders.

This script reads per-dataset manifests in Data/*/PLACEHOLDERS.json and can:
- report current local status against expected file inventories
- download datasets from Google Drive folders into Data/BB and Data/HH

Dependencies:
- Python 3.9+
- gdown (install in current environment)
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = REPO_ROOT / "Data"
MANIFESTS = {
    "BB": DATA_ROOT / "BB" / "PLACEHOLDERS.json",
    "HH": DATA_ROOT / "HH" / "PLACEHOLDERS.json",
}


@dataclass
class DatasetManifest:
    dataset: str
    alias: str
    target_dir: Path
    google_drive_folder_url: str
    files: list[str]

    @property
    def expected_count(self) -> int:
        return len(self.files)


def load_manifest(dataset: str) -> DatasetManifest:
    dataset = dataset.upper()
    if dataset not in MANIFESTS:
        raise ValueError(f"Unknown dataset: {dataset}")

    manifest_path = MANIFESTS[dataset]
    raw = json.loads(manifest_path.read_text(encoding="utf-8"))

    target_dir = REPO_ROOT / raw["target_dir"]
    target_dir.mkdir(parents=True, exist_ok=True)

    return DatasetManifest(
        dataset=raw["dataset"],
        alias=raw.get("alias", raw["dataset"]),
        target_dir=target_dir,
        google_drive_folder_url=raw["google_drive_folder_url"],
        files=raw["files"],
    )


def iter_manifests(selection: str) -> Iterable[DatasetManifest]:
    if selection.lower() == "all":
        for ds in ("BB", "HH"):
            yield load_manifest(ds)
    else:
        yield load_manifest(selection)


def dataset_status(manifest: DatasetManifest) -> tuple[int, int, list[str]]:
    present = []
    missing = []
    for rel in manifest.files:
        path = manifest.target_dir / rel
        if path.exists():
            present.append(rel)
        else:
            missing.append(rel)
    return len(present), manifest.expected_count, missing


def print_status(selection: str) -> int:
    exit_code = 0
    for manifest in iter_manifests(selection):
        present, total, missing = dataset_status(manifest)
        print(f"[{manifest.dataset}] {present}/{total} expected files present in {manifest.target_dir}")
        if missing:
            exit_code = 1
            preview = ", ".join(missing[:5])
            suffix = " ..." if len(missing) > 5 else ""
            print(f"  Missing ({len(missing)}): {preview}{suffix}")
    return exit_code


def ensure_gdown_available() -> None:
    probe = subprocess.run(
        [sys.executable, "-m", "gdown", "--help"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if probe.returncode != 0:
        raise RuntimeError(
            "gdown is not available in this Python environment. "
            "Install it first (e.g., pip install gdown)."
        )


def download_dataset(manifest: DatasetManifest, skip_if_complete: bool) -> None:
    present, total, _ = dataset_status(manifest)
    if skip_if_complete and present == total:
        print(f"[{manifest.dataset}] already complete ({present}/{total}); skipping download.")
        return

    ensure_gdown_available()

    print(f"[{manifest.dataset}] downloading from Google Drive folder into {manifest.target_dir} ...")
    cmd = [
        sys.executable,
        "-m",
        "gdown",
        "--folder",
        manifest.google_drive_folder_url,
        "-O",
        str(manifest.target_dir),
    ]
    subprocess.run(cmd, check=True)

    present_after, total_after, missing_after = dataset_status(manifest)
    print(f"[{manifest.dataset}] post-download status: {present_after}/{total_after} files present")
    if missing_after:
        print(
            f"[{manifest.dataset}] warning: {len(missing_after)} expected files still missing. "
            "Verify Drive sharing permissions and folder contents."
        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Rehydrate BB/HH sequencing data from Drive placeholders.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_status = subparsers.add_parser("status", help="Report local status vs placeholder manifests.")
    p_status.add_argument("dataset", nargs="?", default="all", choices=["BB", "HH", "all"]) 

    p_download = subparsers.add_parser("download", help="Download dataset(s) from Google Drive.")
    p_download.add_argument("dataset", choices=["BB", "HH", "all"])
    p_download.add_argument(
        "--force",
        action="store_true",
        help="Download even if all expected files are already present.",
    )

    args = parser.parse_args()

    if args.command == "status":
        return print_status(args.dataset)

    if args.command == "download":
        for manifest in iter_manifests(args.dataset):
            download_dataset(manifest, skip_if_complete=not args.force)
        return 0

    return 2


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as err:
        print(f"Command failed with exit code {err.returncode}: {err.cmd}", file=sys.stderr)
        raise SystemExit(err.returncode)
    except Exception as exc:  # noqa: BLE001 - user-facing CLI error handling
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)

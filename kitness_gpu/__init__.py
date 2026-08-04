"""GPU backend selection for the cat genomics workflow."""

from __future__ import annotations

import subprocess


def select_backend() -> str:
    """Return the available GPU backend for the current machine."""
    result = subprocess.run(
        ["xcrun", "-f", "metal"],
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode == 0 and result.stdout.strip():
        return "metal"
    return "unavailable"
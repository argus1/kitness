"""GPU backend selection for the cat genomics workflow."""

from __future__ import annotations

import subprocess
from shutil import which


def _probe_command(command: list[str]) -> tuple[bool, str]:
    """Run a command probe and report whether it succeeded."""
    binary = command[0]
    if which(binary) is None:
        return False, f"{binary} not found"

    result = subprocess.run(
        command,
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode == 0:
        return True, "available"
    return False, (result.stderr or result.stdout or "probe failed").strip()


def backend_capabilities() -> dict[str, dict[str, object]]:
    """Return backend availability and stub status by backend name."""
    cuda_ok, cuda_detail = _probe_command(["nvidia-smi"])
    metal_ok, metal_detail = _probe_command(["xcrun", "-f", "metal"])

    return {
        "cuda": {
            "backend": "cuda",
            "available": cuda_ok,
            "status": "available" if cuda_ok else "unavailable",
            "detail": cuda_detail,
        },
        "metal": {
            "backend": "metal",
            "available": metal_ok,
            "status": "available" if metal_ok else "unavailable",
            "detail": metal_detail,
        },
        "rocm": {
            "backend": "rocm",
            "available": False,
            "status": "stub",
            "detail": "hipcc probe not implemented in Sprint 1",
        },
        "oneapi": {
            "backend": "oneapi",
            "available": False,
            "status": "stub",
            "detail": "dpcpp probe not implemented in Sprint 1",
        },
    }


def select_backend() -> str:
    """Return the available GPU backend for the current machine."""
    capabilities = backend_capabilities()
    if capabilities["cuda"]["available"]:
        return "cuda"
    if capabilities["metal"]["available"]:
        return "metal"
    return "unavailable"
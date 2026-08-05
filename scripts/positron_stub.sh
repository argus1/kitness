#!/usr/bin/env bash
set -euo pipefail

# Positron integration stub.
# TODO: resolve and export project-specific R and Python paths for Positron.
# TODO: validate required command-line tools before launching tasks.
# TODO: wire this script into a future Positron task profile.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[positron-stub] workspace: ${ROOT_DIR}"
echo "[positron-stub] TODO: bootstrap Positron runtime environment"
echo "[positron-stub] TODO: run r/kitnessGpu/examples/positron_stub.R"

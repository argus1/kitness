#!/usr/bin/env bash
set -euo pipefail

# Positron integration stub.
# TODO: resolve and export project-specific R and Python paths for Positron.
# TODO: validate required command-line tools before launching tasks.
# TODO: wire this script into a future Positron task profile.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CUDA_ENV="${CUDA_ENV:-/home/argus/anaconda3/envs/cellpose}"

if [[ -x "${CUDA_ENV}/bin/nvcc" ]]; then
  echo "[positron-stub] using CUDA 11.6 toolchain from ${CUDA_ENV}"
  export PATH="${CUDA_ENV}/bin:${PATH}"
else
  echo "[positron-stub] warning: CUDA 11.6 toolchain not found at ${CUDA_ENV}" 
fi

echo "[positron-stub] workspace: ${ROOT_DIR}"
echo "[positron-stub] TODO: bootstrap Positron runtime environment"
echo "[positron-stub] TODO: run r/kitnessGpu/examples/positron_stub.R"

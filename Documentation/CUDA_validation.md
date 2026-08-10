# CUDA Validation on Local Development Machine

Date: 2026-08-09
Host OS: Linux

## Probe Results

- `nvidia-smi`: available
- Reported GPU: NVIDIA GeForce RTX 2080 Ti
- Driver CUDA version: 13.2
- `nvcc --version`: not available (`nvcc` not found)

## Repository Validation Commands

- `python -m unittest discover -s tests -v`
- `python - <<'PY' ...` probe using `kitness_gpu.backend_capabilities()` and `kitness_gpu.select_backend()`

## Observed Behavior

- Selected backend on this host: `cuda`
- Capability statuses:
  - `cuda`: `available`
  - `metal`: `unavailable`
  - `rocm`: `stub`
  - `oneapi`: `stub`

## Notes

This validates runtime CUDA availability for backend selection. Native CUDA bridge
build work remains blocked until CUDA toolkit compiler support (`nvcc`) is
installed and wired into the R package build.

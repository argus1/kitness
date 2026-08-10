# CUDA Validation on Local Development Machine

Date: 2026-08-09
Host OS: Linux

## Probe Results

- `nvidia-smi`: available
- Reported GPU: NVIDIA GeForce RTX 2080 Ti
- Driver CUDA version: 13.2
- CUDA compiler: `nvcc` 11.6.124 from the `cellpose` Conda environment
- CUDA host compiler: Conda GCC 11.2.0

## Repository Validation Commands

- `python -m unittest discover -s tests -v`
- `R CMD build r/kitnessGpu`
- `R CMD check --no-manual kitnessGpu_0.0.0.9000.tar.gz`
- Conditional package install with `nvcc` hidden from `PATH`

## Observed Behavior

- Selected backend on this host: `cuda`
- CUDA native bridge compiled: `TRUE`
- CUDA numeric round trip: passed
- Capability statuses:
  - `cuda`: `available`
  - `metal`: `unavailable`
  - `rocm`: `stub`
  - `oneapi`: `stub`

## Notes

The R package conditionally builds a registered `.Call()` CUDA bridge when
`nvcc` is available. The bridge owns device memory and a CUDA stream, performs
asynchronous host-to-device and device-to-host copies, synchronizes before
returning to R, and translates CUDA failures into R errors. Without `nvcc`, the
package installs a native unavailable-backend stub and does not select CUDA.

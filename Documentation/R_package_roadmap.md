# R Package Expansion Roadmap

## Current foundation

The `r/kitnessGpu` package now provides a backend-neutral capability contract through `kitnessGpu::gpu_capabilities()` and `kitnessGpu::gpu_backend()`. Runtime selection prioritizes CUDA when an NVIDIA runtime is present, falls back to Metal when available, and otherwise reports `"unavailable"`.

## Next package increments

1. Define the input and output contract for a motif-scanning workflow before adding `gpu_scan_motifs()`.
2. Add an R interface for FASTQ quality-score summary only after a representative input fixture is available.
3. Record the selected backend and Metal toolchain version in each workflow result for reproducibility.
4. Add Bioconductor interoperability after the first workflow has a stable return type, beginning with Biostrings-compatible sequence inputs.
5. Introduce Vulkan and OpenCL adapters behind the existing backend interfaces when their platform contracts are specified.

## Deferred platform work

Native CUDA bridge build work remains deferred until CUDA toolkit compiler support (`nvcc`) is installed and integrated into the package toolchain. The public CUDA capability and selection interfaces are now active and validated through runtime probes.

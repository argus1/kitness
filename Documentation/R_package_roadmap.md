# R Package Expansion Roadmap

## Current foundation

The `r/kitnessGpu` package provides `kitnessGpu::gpu_backend()`, a Metal-only backend check validated on the local macOS development machine. The package has no CUDA code or CUDA dependency.

## Next package increments

1. Define the input and output contract for a motif-scanning workflow before adding `gpu_scan_motifs()`.
2. Add an R interface for FASTQ quality-score summary only after a representative input fixture is available.
3. Record the selected backend and Metal toolchain version in each workflow result for reproducibility.
4. Add Bioconductor interoperability after the first workflow has a stable return type, beginning with Biostrings-compatible sequence inputs.
5. Introduce Vulkan and OpenCL adapters behind the existing backend interfaces when their platform contracts are specified.

## Deferred platform work

CUDA remains deferred until NVIDIA hardware and the CUDA SDK are available. A future CUDA implementation must be added behind the existing public interfaces and include platform-specific validation before it is enabled.

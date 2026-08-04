# R Package Scope and Initial API

## Package goal

The `kitnessGpu` R package will provide a small R-facing entry point for GPU-enabled cat genomics workflows. Sprint 4 establishes the package shape around native Metal support on macOS; it does not implement CUDA support.

The package will support R and Bioconductor workflows by reporting the selected backend before a GPU workflow runs. Domain-specific operations such as motif scanning and FASTQ QC will be added only after their inputs and outputs are defined.

## Initial public API

The first entry point will be:

```r
gpu_backend()
```

It returns one of the following character values:

- `"metal"` when the local Metal toolchain is available
- `"unavailable"` when no supported backend is available

The R function uses the same `xcrun -f metal` probe as the existing Python public interface, `kitness_gpu.select_backend()`, so both interfaces report the same Metal availability contract without requiring a cross-language runtime dependency.

## R-facing test seam

The confirmed public seam is `kitnessGpu::gpu_backend()`. Its behavior is tested by calling that exported function from R and observing the returned backend name; tests do not inspect package internals or invoke the Metal compiler directly.

## Platform scope

- Metal is the only enabled backend for this sprint.
- CUDA is deferred until NVIDIA hardware and the CUDA SDK are available.
- Vulkan and OpenCL are reserved for later compatibility adapters.
- R 4.4 or later is required to run the package scaffold and example locally.

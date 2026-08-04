# kitnessGpu

`kitnessGpu` exposes a small R interface for Metal-backed cat genomics workflows.

## Metal backend check

Install the package from the repository root, then query the available backend:

```r
install.packages("r/kitnessGpu", repos = NULL, type = "source")
kitnessGpu::gpu_backend()
#> [1] "metal"
```

Only Metal is enabled. CUDA remains deferred until an NVIDIA-capable platform and CUDA SDK are available.

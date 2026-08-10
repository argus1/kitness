# kitnessGpu

`kitnessGpu` exposes a small R interface for backend-neutral GPU capability
discovery used by cat genomics workflows.

## Backend checks

Install the package from the repository root, then query the available backend:

```r
install.packages("r/kitnessGpu", repos = NULL, type = "source")
kitnessGpu::gpu_backend()
#> [1] "cuda" | "metal" | "unavailable"

kitnessGpu::gpu_capabilities()
#> $cuda
#> $metal
#> $rocm
#> $oneapi
```

Selection priority is `cuda` first, then `metal`, then `unavailable`.

`rocm` and `oneapi` are currently documented stubs to preserve a backend-neutral
public contract while their native bridges and integration tests are pending.

## Positron integration stub

This package includes starter stubs for future Positron-based workflows.

1. Copy the template settings file into your local VS Code settings workflow and fill in interpreter paths from your machine.
2. Run the shell bootstrap stub from the repository root:

```bash
bash scripts/positron_stub.sh
```

3. Run the R integration stub to verify basic tool discovery and backend reporting:

```r
source("r/kitnessGpu/examples/positron_stub.R")
```

The files are intentionally placeholders and document TODO points for complete task automation in a later sprint.

## Positron tasks and CI validation

The repository now includes a real task configuration in `.vscode/tasks.json` for running the stub flow in sequence:

```text
Positron: Bootstrap Stub Environment
Positron: Run R Stub Diagnostics
Positron: Validate Stub Files
Positron: Full Stub Validation
```

A lightweight CI workflow at `.github/workflows/positron-stubs.yml` runs `scripts/check_positron_stubs.sh` and fails if required Positron stub files are missing.

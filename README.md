# kitness

Cat Genomics

This project outlines a bioinformatics development plan for comparing collagen-related genomic variation in Rag Doll and Maine Coon cats. The goal is to build a reproducible workflow that integrates sequencing analysis, variant interpretation, and comparative sequence analysis. The effort is intended to support a clear, evidence-based investigation of breed-specific genomic differences and their potential biological significance.
![cats](https://github.com/argus1/kitness/blob/main/cats.png)

## Large data handling (BB / HH)

Sequencing files are intentionally **not** stored in git or git-lfs due to size limits.

- `Data/BB/PLACEHOLDERS.json` stores per-file placeholders for BaiBai (`BB`) plus Drive folder metadata.
- `Data/HH/PLACEHOLDERS.json` stores per-file placeholders for HuaHua (`HH`) plus Drive folder metadata.
- `scripts/prepare_data.py` bootstraps local datasets for teammates who have disk capacity.

### Bootstrap local data

1. Ensure Python is available.
2. Install `gdown` in your environment.
3. Run the data prep script:
	- `python scripts/prepare_data.py status`
	- `python scripts/prepare_data.py download BB`
	- `python scripts/prepare_data.py download HH`
	- or `python scripts/prepare_data.py download all`

The script downloads directly from the shared Google Drive folders into `Data/BB` and `Data/HH`, then reports how many expected files are present.

## Positron stub automation

- Workspace tasks for Positron stubs are defined in `.vscode/tasks.json`.
- Run the full local stub check from VS Code using the task `Positron: Full Stub Validation`.
- CI validates required Positron stub files using `.github/workflows/positron-stubs.yml`.

## GPU backend capability contract

The repository now uses a backend-neutral capability contract in both Python and R entry points:

- Python: `kitness_gpu.backend_capabilities()` and `kitness_gpu.select_backend()`
- R: `kitnessGpu::gpu_capabilities()` and `kitnessGpu::gpu_backend()`

Runtime selection priority is `cuda` first, then `metal`, then `unavailable`.

ROCm (`rocm`) and oneAPI (`oneapi`) are currently explicit stubs so the public
interface remains backend-neutral while native integrations are developed.

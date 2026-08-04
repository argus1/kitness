# Metal Development Setup

Sprint 1 targets native Metal execution on macOS. CUDA is intentionally out of scope until an NVIDIA-capable development environment is available.

## Required tools

- macOS 26 or later
- Xcode 26.6 or later, including the Metal toolchain
- Python 3.9 or later
- R 4.4 or later for the planned R-facing analysis interface
- Bioconductor packages will be selected when the first R-facing workflow is defined

Install the command-line tools and R with Homebrew:

```sh
xcode-select --install
brew install r
```

Verify the environment from the repository root:

```sh
xcodebuild -version
xcrun --sdk macosx --show-sdk-version
xcrun -f metal
python3 --version
R --version
```

The `metal` command must resolve to the Xcode Metal toolchain. `R --version` must report an R 4.4 or newer installation before R-facing GPU functions can be developed.

## Validated local baseline

The current development machine has the following verified components:

- macOS 26.5.2
- Xcode 26.6 (build 17F113)
- macOS SDK 26.5
- Metal compiler 7.6.109.0
- Python 3.9.6

R is not installed on this machine. Install and verify R before beginning the R integration work.

## Sprint 1 limitations

- Only the Metal backend will be implemented and validated in Sprint 1.
- CUDA detection and execution are deferred until NVIDIA hardware and the CUDA SDK are available.
- Vulkan and OpenCL compatibility remain future extension points; no compatibility backend is enabled yet.
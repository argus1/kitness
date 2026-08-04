# GPU Acceleration Roadmap for the Cat Genomics Project

## Purpose

This roadmap outlines how the project can use GPU acceleration to support large-scale bioinformatics workflows while also advancing a longer-term goal: producing useful R and Bioconductor-facing packages that help researchers apply GPU computing in a reproducible and extensible way.

## Sprint 1 target

The preferred near-term outcome is a GPU deliverable by the end of Sprint 1. This should be a focused proof-of-concept that demonstrates at least one end-to-end accelerated workflow, such as GPU-backed motif scanning, FASTQ QC summarization, or a simple variant-filtering step that can be validated against existing project data.

The roadmap is designed around three priorities:

1. Accelerate the most compute-heavy parts of the workflow.
2. Make GPU support accessible to researchers through R-friendly interfaces.
3. Preserve compatibility with existing OpenCL-based R workflows and allow users to inject their own custom kernels into analysis pipelines.

---

## 1. Why GPU acceleration fits this project

The current workflow involves several compute-intensive tasks:

- FASTQ quality screening and preprocessing over millions of reads
- Alignment scoring and coverage summarization
- Variant comparison across large VCF and genotype matrices
- Sequence reconstruction and consensus generation
- Motif and PTM scanning across many sequences
- Large-scale table operations for annotations and summaries

These steps are good candidates for GPU execution because they can be expressed as highly parallel operations over arrays, strings, or genomic windows.

---

## 2. Project-level goals

### A. Scientific throughput

Use GPU acceleration to reduce wall-clock time for routine analyses such as:

- read QC and trimming workflows
- variant QC and concordance analysis
- motif scanning and sequence comparison
- large-scale annotation joins and filtering

### B. Researcher-facing R and Bioconductor packages

A major goal is not just to accelerate one-off scripts, but to create reusable packages that support researcher needs in a standardized way. These packages should:

- expose GPU-backed operations through simple R interfaces
- preserve reproducibility and provenance
- work well with Bioconductor-style workflows
- be extensible for custom analyses and domain-specific kernels

### C. Compatibility and extensibility

The roadmap should support a transition path for existing OpenCL-based R workflows. In practical terms, that means allowing a user to provide a custom kernel function or kernel source while the package dispatches it to the correct backend for the current machine.

---

## 3. Recommended acceleration targets

### Phase 1: Highest-value, lowest-risk targets

These are ideal starting points because they are parallelizable and do not require full rewrite of the existing pipeline:

- FASTQ QC statistics over many reads
- k-mer or motif scanning across many sequences
- simple genotype matrix operations
- variant filtering and comparison across VCF-derived tables
- sequence motif search for collagen-related signatures

### Phase 2: More advanced integration

Once the initial kernels are stable, add support for:

- alignment scoring kernels for short-read style workflows
- coverage and depth summary kernels
- approximate sequence comparison kernels
- GPU-backed annotation and filtering operations

---

## 4. Architecture vision

A practical design should separate three layers:

### Layer 1: High-level R interface

Provide R functions such as:

- `gpu_qc_fastq()`
- `gpu_compare_variants()`
- `gpu_scan_motifs()`
- `gpu_align_scores()`

These should accept familiar inputs such as FASTQ-derived tables, VCF tables, FASTA sequences, or GenomicRanges-like objects.

### Layer 2: Backend abstraction

A backend layer should select the appropriate execution engine based on the platform:

- CUDA for NVIDIA GPUs
- Metal for Apple Silicon and macOS systems
- Vulkan for cross-platform compute workloads and future portability
- OpenCL or OpenCLOn12 compatibility for legacy workflows and Windows compatibility

The ideal design is backend-agnostic so that the same R function can dispatch to different implementations without changing user code.

### Layer 3: Kernel dispatch layer

This is the most important feature for long-term usefulness. The package should allow a researcher to provide a custom kernel function or kernel source and route it into the workflow.

This could include:

- a generic `dispatch_kernel()` interface
- a small kernel description object that contains function name, data layout, and expected outputs
- a backend adapter that translates the request into CUDA, Metal, Vulkan, or OpenCL execution

This would make the project more than a fixed pipeline and would support community-driven extensions.

---

## 5. OpenCL compatibility strategy

Because the project explicitly wants to preserve compatibility with OpenCL-based R packages, the roadmap should include a compatibility layer rather than treating OpenCL as obsolete.

### Recommended approach

- Keep OpenCL as a compatibility interface for existing workflows.
- Implement a thin adapter that accepts OpenCL kernel source or precompiled kernel metadata.
- Route execution to a supported backend on the host system:
  - OpenCL on systems where it is already available
  - OpenCLOn12 on Windows for compatibility with existing OpenCL-based code
  - Metal on macOS for native Apple GPU execution
  - Vulkan as a lower-level cross-platform compute backend where appropriate

### Why this matters

This allows users to preserve existing code while gradually moving to more modern backends. It also avoids forcing a hard break for researchers who already rely on OpenCL-based R packages.

---

## 6. Vulkan and OpenCLOn12 considerations

### Vulkan

Vulkan is worth considering as a long-term compute backend because it provides:

- strong cross-platform portability
- explicit control over GPU resource management
- good fit for modern compute shaders
- a future-proof path beyond older OpenCL abstractions

Vulkan is especially attractive if the project wants to support more than one operating system and hardware vendor over time.

### OpenCLOn12

OpenCLOn12 is useful as a compatibility bridge for Windows environments. It can help preserve compatibility with OpenCL-based software and reduce friction for users who already rely on OpenCL kernels in R workflows.

This is particularly valuable if the project wants to support:

- legacy OpenCL kernels
- existing research code that is not yet rewritten for Metal or Vulkan
- Windows-based compute environments in academic or institutional settings

A sensible approach is to use OpenCLOn12 as a compatibility layer while building new functionality around a more modern abstraction.

---

## 7. Suggested package structure

The project could evolve toward a small family of packages rather than one monolithic GPU package.

### Suggested package themes

- A core package for GPU execution primitives and backend abstraction
- A sequence-analysis package for FASTQ, alignment, and motif scanning
- A variant-analysis package for VCF filtering, concordance, and genotype operations
- A researcher-extensions package for custom kernel registration and dispatch

The package APIs should remain simple enough for biological researchers while still accommodating advanced users who want to write their own kernels.

---

## 8. Implementation plan

### Milestone 1: Prototype on macOS with Metal

- Build a minimal GPU prototype for one simple task such as motif scanning or quality-score summarization.
- Validate the performance gain on Apple Silicon hardware.
- Establish a simple R-facing interface that can later be reused by other workflows.

### Milestone 2: Add backend abstraction

- Create a backend selection layer that can dispatch to Metal, CUDA, Vulkan, or OpenCL.
- Make the package capable of selecting the best backend automatically based on the host environment.

### Milestone 3: Add OpenCL compatibility bridge

- Support execution of existing OpenCL kernels through an adapter layer.
- Add OpenCLOn12 support for Windows workflows.
- Preserve compatibility for researchers who already depend on OpenCL-based R packages.

### Milestone 4: Expose custom-kernel dispatch

- Implement a generic interface for user-supplied kernels.
- Allow a researcher to provide kernel source or a compiled kernel descriptor and plug it into a workflow.
- Make the interface explicit and documented so that it is useful beyond the project’s internal analyses.

### Milestone 5: Package hardening and Bioconductor readiness

- Improve portability, validation, and documentation.
- Add benchmarking reports and examples.
- Ensure the interfaces are clear for biological researchers and package maintainers.

---

## 9. Technical considerations

### Software stack

Potential technologies include:

- Rcpp and RcppParallel for low-level integration with R
- C++ kernels with backend-specific wrappers
- Metal Shaders/Objective-C++ for Apple platforms
- CUDA kernels for NVIDIA environments
- Vulkan compute shaders for broader portability
- OpenCL and OpenCLOn12 as compatibility bridges

### API design guidance

The GPU-facing APIs should:

- be explicit about inputs and outputs
- avoid requiring users to understand backend internals
- support both simple built-in workflows and advanced custom kernels
- preserve reproducibility with clear logging and metadata

### Performance expectations

The best early wins will come from tasks that are:

- embarrassingly parallel
- memory-bandwidth friendly
- easy to express as vectorized operations

These include QC summaries, motif scanning, genotype matrix operations, and large-scale filtering.

---

## 10. Risks and mitigation

### Risk: Too much complexity too early

Mitigation: Start with one or two simple kernels and expand gradually.

### Risk: Backend fragmentation

Mitigation: Keep core package logic backend-agnostic and isolate backend-specific code behind adapters.

### Risk: Poor usability for researchers

Mitigation: Expose simple R functions and avoid requiring knowledge of CUDA, Vulkan, or Metal unless the user explicitly wants advanced control.

### Risk: Legacy compatibility breakage

Mitigation: Preserve OpenCL compatibility and provide migration paths rather than forcing immediate replacement.

---

## 11. Recommended near-term decision

The strongest first step is to build a small proof-of-concept GPU workflow around one of the most parallel tasks in the project, such as:

- motif scanning for collagen-related sequence features, or
- rapid QC summary generation over FASTQ-derived data.

At the same time, the package design should be created with the following future capabilities in mind:

- user-defined kernel dispatch
- OpenCL compatibility
- Metal support on macOS
- Vulkan support for broader portability
- eventual R/Bioconductor packaging and documentation

This approach keeps the project scientifically useful now while also building toward a reusable and extensible GPU-enabled research software stack.

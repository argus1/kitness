# Sprint 1 Review: GPU Proof-of-Concept for Motif Scanning

## Summary

This sprint delivers a working proof-of-concept comparing a CPU baseline
against a Metal-backed GPU implementation for a simple DNA motif counting
task. Both implementations produce identical results, and the GPU path
shows a measurable speedup on the target hardware.

## Target workload

- **Task**: Count occurrences of a fixed motif ("GGT") within a DNA sequence.
- **Benchmark dataset**: A randomly generated DNA sequence (seed=42) of
  1,000,000 bases, using the four standard nucleotide bases (A, T, C, G).
- **Rationale**: Motif counting is a simple, well-bounded, and highly
  parallelizable task, making it a good first target to validate the GPU
  development environment and confirm correctness before tackling more
  complex workloads (e.g., FASTQ QC or collagen-specific motif scanning).

## Implementation

- **CPU baseline** (`count_motif_cpu`): A straightforward Python loop that
  checks every position in the sequence for a match against the motif.
- **GPU path** (`count_motif_gpu`): Implemented using the `metalcompute`
  library, which runs a custom Metal Shading Language kernel on the
  device's native GPU. The sequence and motif are encoded as byte arrays
  (A/T/C/G mapped to 0/1/2/3) and passed to the GPU as buffers. Each GPU
  thread checks one starting position in parallel, and matches are
  accumulated using an atomic counter.
- Code lives in `kitness_gpu/motif_scan.py` and builds on the existing
  `kitness_gpu.select_backend()` Metal detection utility from Sprint 1's
  backend abstraction work.

## Environment

- Hardware: Apple M1 (unified memory)
- Backend: Metal (via `metalcompute` 0.2.9)
- CUDA was not used, consistent with the project's current scope — CUDA
  support remains deferred until NVIDIA hardware is available (see
  `Documentation/Metal_setup.md`).

## Results

| Metric | CPU | GPU (Metal) |
|---|---|---|
| Motif count | 15,500 | 15,500 |
| Runtime | 0.1337 s | 0.0745 s |

- **Correctness**: GPU and CPU results match exactly (15,500 occurrences).
- **Speedup**: ~1.79x on a 1,000,000-base sequence.

## Observations and limitations

- At this sequence length, the speedup is modest. GPU dispatch has fixed
  overhead (kernel compilation, buffer setup, data transfer), so the
  relative benefit is expected to grow with larger, more realistic
  sequence lengths (e.g., full gene-length or chromosome-scale inputs).
- This proof-of-concept uses a simulated random sequence rather than real
  sequencing data. The BB and HH datasets (Google Drive-hosted FASTQ/gVCF)
  are available and access has been confirmed; substituting real
  COL1A1-region sequence data is a natural next step.
- The current kernel only supports single motif matching without
  mismatches; extending it to ambiguous bases or approximate matching
  would require additional kernel logic.

## Next steps

1. Re-run the benchmark with a longer, more realistic sequence length to
   better characterize how speedup scales with input size.
2. Substitute the simulated sequence with a real sequence extracted from
   the BB/HH dataset (e.g., the COL1A1 gene region) once that extraction
   step is available.
3. Extend the kernel to scan for multiple motifs (e.g., glycine-X-Y
   collagen repeat patterns) in a single pass, in line with the project's
   Sprint 3 collagen motif analysis goals.
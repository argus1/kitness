"""Motif scanning proof-of-concept: CPU baseline vs Metal GPU path."""

from __future__ import annotations

import random
import time


def generate_sequence(length: int, seed: int = 42) -> str:
    """Generate a random DNA sequence for benchmarking."""
    random.seed(seed)
    bases = ["A", "T", "C", "G"]
    return "".join(random.choices(bases, k=length))


def count_motif_cpu(sequence: str, motif: str) -> int:
    """Count occurrences of a motif in a sequence using a plain CPU loop."""
    count = 0
    for i in range(len(sequence) - len(motif) + 1):
        if sequence[i:i + len(motif)] == motif:
            count += 1
    return count


BASE_TO_CODE = {"A": 0, "T": 1, "C": 2, "G": 3}

METAL_KERNEL_SOURCE = """
#include <metal_stdlib>
using namespace metal;

kernel void count_motif(const device uchar *sequence [[ buffer(0) ]],
                         const device uchar *motif [[ buffer(1) ]],
                         constant uint &motif_len [[ buffer(2) ]],
                         constant uint &seq_len [[ buffer(3) ]],
                         device atomic_uint *result [[ buffer(4) ]],
                         uint id [[ thread_position_in_grid ]]) {
    if (id > seq_len - motif_len) {
        return;
    }
    for (uint i = 0; i < motif_len; i++) {
        if (sequence[id + i] != motif[i]) {
            return;
        }
    }
    atomic_fetch_add_explicit(result, 1, memory_order_relaxed);
}
"""


def encode_sequence(sequence: str) -> bytes:
    """Convert a DNA sequence string into a byte array of base codes."""
    return bytes(BASE_TO_CODE[base] for base in sequence)


def count_motif_gpu(sequence: str, motif: str) -> tuple[int, float]:
    """Count occurrences of a motif in a sequence using a Metal GPU kernel."""
    import metalcompute as mc

    dev = mc.Device()
    kernel_fn = dev.kernel(METAL_KERNEL_SOURCE).function("count_motif")

    seq_bytes = encode_sequence(sequence)
    motif_bytes = encode_sequence(motif)

    buf_sequence = dev.buffer(seq_bytes)
    buf_motif = dev.buffer(motif_bytes)
    buf_motif_len = dev.buffer(4)
    buf_seq_len = dev.buffer(4)
    buf_result = dev.buffer(4)

    memoryview(buf_motif_len).cast("I")[0] = len(motif)
    memoryview(buf_seq_len).cast("I")[0] = len(sequence)
    memoryview(buf_result).cast("I")[0] = 0

    start = time.time()
    kernel_fn(
        len(sequence),
        buf_sequence,
        buf_motif,
        buf_motif_len,
        buf_seq_len,
        buf_result,
    )
    elapsed = time.time() - start

    result = memoryview(buf_result).cast("I")[0]
    return result, elapsed


if __name__ == "__main__":
    sequence = generate_sequence(length=1_000_000)
    motif = "GGT"

    start = time.time()
    cpu_result = count_motif_cpu(sequence, motif)
    cpu_elapsed = time.time() - start

    print(f"Sequence length: {len(sequence)}")
    print(f"Motif: {motif}")
    print(f"CPU count: {cpu_result}")
    print(f"CPU time: {cpu_elapsed:.4f} seconds")

    gpu_result, gpu_elapsed = count_motif_gpu(sequence, motif)
    print(f"GPU count: {gpu_result}")
    print(f"GPU time: {gpu_elapsed:.4f} seconds")

    if gpu_result == cpu_result:
        print("Results match between CPU and GPU.")
    else:
        print(f"MISMATCH: CPU={cpu_result} GPU={gpu_result}")

    if gpu_elapsed > 0:
        speedup = cpu_elapsed / gpu_elapsed
        print(f"Speedup: {speedup:.2f}x")
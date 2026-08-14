# OpenCL motif scanning example
#
# This example demonstrates a small DNA motif search using OpenCL.
# It is designed as a simple, reproducible example that can be
# extended to larger datasets after the hackathon.

library(OpenCL)

# 1. Define a small DNA sequence and motif
sequence <- "GGTACGGT"
motif <- "GGT"

# 2. Encode DNA bases as numeric values
BASE_TO_CODE <- c(A = 0, T = 1, C = 2, G = 3)

sequence_codes <- unname(
    BASE_TO_CODE[strsplit(sequence, "")[[1L]]]
)

motif_codes <- unname(
    BASE_TO_CODE[strsplit(motif, "")[[1L]]]
)

# 3. CPU reference implementation
cpu_motif_count <- function(sequence_codes, motif_codes) {
    n <- length(sequence_codes) - length(motif_codes) + 1L

    if (n <= 0L) {
        return(0L)
    }

    count <- 0L

    for (i in seq_len(n)) {
        if (all(
            sequence_codes[
                i:(i + length(motif_codes) - 1L)
            ] == motif_codes
        )) {
            count <- count + 1L
        }
    }

    count
}

# 4. Define the OpenCL kernel
kernel_source <- "
__kernel void motif_match(
    __global double* output,
    const unsigned int n,
    __global const double* sequence,
    __global const double* motif,
    const unsigned int motif_len
) {
    int i = get_global_id(0);

    if (i >= n) {
        return;
    }

    int match = 1;

    for (int j = 0; j < motif_len; j++) {
        if (sequence[i + j] != motif[j]) {
            match = 0;
            break;
        }
    }

    output[i] = (double) match;
}
"

# 5. Create the OpenCL context and kernel
ctx <- OpenCL::oclContext()

kernel <- OpenCL::oclSimpleKernel(
    ctx,
    "motif_match",
    kernel_source,
    output.mode = "double"
)

# 6. Copy the input data to OpenCL buffers
sequence_buffer <- OpenCL::as.clBuffer(
    as.double(sequence_codes),
    ctx
)

motif_buffer <- OpenCL::as.clBuffer(
    as.double(motif_codes),
    ctx
)

# 7. Run the OpenCL kernel
n <- length(sequence_codes) - length(motif_codes) + 1L

matches <- OpenCL::oclRun(
    kernel,
    n,
    sequence_buffer,
    motif_buffer,
    length(motif_codes)
)

# 8. Count the matching positions
gpu_result <- as.integer(
    sum(as.numeric(matches))
)

# 9. Compare the OpenCL result with the CPU reference
cpu_result <- cpu_motif_count(
    sequence_codes,
    motif_codes
)

cat("Sequence:", sequence, "\n")
cat("Motif:", motif, "\n")
cat("CPU matches:", cpu_result, "\n")
cat("OpenCL matches:", gpu_result, "\n")
cat("Results identical:", identical(cpu_result, gpu_result), "\n")

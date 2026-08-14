#' Count DNA motif matches using OpenCL
#'
#' Dispatches a simple DNA motif-matching kernel through OpenCL and
#' returns the number of matching positions.
#'
#' @param sequence_codes Numeric vector containing encoded DNA bases.
#'   Use A=0, T=1, C=2, G=3.
#' @param motif_codes Numeric vector containing the encoded motif.
#' @return An integer count of motif matches.
#' @export
gpu_motif_count_opencl <- function(sequence_codes, motif_codes) {
    if (!is.numeric(sequence_codes) || is.object(sequence_codes)) {
        stop("`sequence_codes` must be an ordinary numeric vector", call. = FALSE)
    }

    if (!is.numeric(motif_codes) || is.object(motif_codes)) {
        stop("`motif_codes` must be an ordinary numeric vector", call. = FALSE)
    }

    sequence_codes <- as.double(sequence_codes)
    motif_codes <- as.double(motif_codes)

    if (length(motif_codes) == 0L) {
        stop("`motif_codes` must not be empty", call. = FALSE)
    }

    n <- length(sequence_codes) - length(motif_codes) + 1L

    if (n <= 0L) {
        return(0L)
    }

    ctx <- OpenCL::oclContext()

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

    kernel <- OpenCL::oclSimpleKernel(
        ctx,
        "motif_match",
        kernel_source,
        output.mode = "double"
    )

    sequence_buffer <- OpenCL::as.clBuffer(sequence_codes, ctx)
    motif_buffer <- OpenCL::as.clBuffer(motif_codes, ctx)

    matches <- OpenCL::oclRun(
        kernel,
        n,
        sequence_buffer,
        motif_buffer,
        length(motif_codes)
    )

    as.integer(sum(as.numeric(matches)))
}

#' Select the available GPU backend
#'
#' Detects the native Metal compiler available through the macOS developer
#' toolchain. CUDA support is intentionally deferred.
#'
#' @return A character string, either `"metal"` or `"unavailable"`.
#' @export
gpu_backend <- function() {
    xcrun <- Sys.which("xcrun")
    if (!nzchar(xcrun)) {
        return("unavailable")
    }

    output <- suppressWarnings(system2(
        xcrun,
        args = c("-f", "metal"),
        stdout = TRUE,
        stderr = TRUE
    ))
    status <- attr(output, "status")

    if (is.null(status) && length(output) > 0L && nzchar(trimws(output[[1L]]))) {
        return("metal")
    }

    "unavailable"
}

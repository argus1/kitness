#' Probe GPU backend capabilities
#'
#' Reports availability for current and planned backends through a backend-
#' neutral capability contract.
#'
#' @return A named list with entries for `"cuda"`, `"metal"`, `"rocm"`, and
#'   `"oneapi"`.
#' @export
gpu_capabilities <- function() {
    cuda <- .probe_backend_command("nvidia-smi")
    metal <- .probe_backend_command("xcrun", c("-f", "metal"))

    hipcc <- Sys.which("hipcc")
    dpcpp <- Sys.which("dpcpp")

    list(
        cuda = list(
            backend = "cuda",
            available = cuda$available,
            status = if (cuda$available) "available" else "unavailable",
            detail = cuda$detail
        ),
        metal = list(
            backend = "metal",
            available = metal$available,
            status = if (metal$available) "available" else "unavailable",
            detail = metal$detail
        ),
        rocm = list(
            backend = "rocm",
            available = FALSE,
            status = "stub",
            detail = if (nzchar(hipcc)) {
                sprintf("hipcc detected at %s (execution unavailable in Sprint 1)", hipcc)
            } else {
                "hipcc not found (execution unavailable in Sprint 1)"
            }
        ),
        oneapi = list(
            backend = "oneapi",
            available = FALSE,
            status = "stub",
            detail = if (nzchar(dpcpp)) {
                sprintf("dpcpp detected at %s (execution unavailable in Sprint 1)", dpcpp)
            } else {
                "dpcpp not found (execution unavailable in Sprint 1)"
            }
        )
    )
}

#' Select the available GPU backend
#'
#' Chooses `"cuda"` when an NVIDIA runtime is available, falls back to
#' `"metal"` when the native Metal toolchain is available, and returns
#' `"unavailable"` otherwise.
#'
#' @return A character string, one of `"cuda"`, `"metal"`, or `"unavailable"`.
#' @export
gpu_backend <- function() {
    capabilities <- gpu_capabilities()
    if (isTRUE(capabilities$cuda$available)) {
        return("cuda")
    }
    if (isTRUE(capabilities$metal$available)) {
        return("metal")
    }
    "unavailable"
}

.probe_backend_command <- function(command, args = character()) {
    binary <- Sys.which(command)
    if (!nzchar(binary)) {
        return(list(available = FALSE, detail = sprintf("%s not found", command)))
    }

    output <- suppressWarnings(system2(
        binary,
        args = args,
        stdout = TRUE,
        stderr = TRUE
    ))
    status <- attr(output, "status")
    succeeded <- is.null(status)

    if (succeeded) {
        return(list(available = TRUE, detail = "available"))
    }

    detail <- if (length(output) > 0L) trimws(output[[1L]]) else "probe failed"
    list(available = FALSE, detail = detail)
}

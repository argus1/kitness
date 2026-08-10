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
    cuda_compiled <- isTRUE(.Call(
        "kitness_cuda_compiled",
        PACKAGE = "kitnessGpu"
    ))
    metal <- .probe_backend_command("xcrun", c("-f", "metal"))

    hipcc <- Sys.which("hipcc")
    dpcpp <- Sys.which("dpcpp")

    list(
        cuda = list(
            backend = "cuda",
            available = cuda$available && cuda_compiled,
            compiled = cuda_compiled,
            status = if (cuda$available && cuda_compiled) "available" else "unavailable",
            detail = if (!cuda_compiled) {
                "CUDA runtime detected but native bridge was not compiled"
            } else {
                cuda$detail
            }
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

#' Round-trip numeric values through a GPU backend
#'
#' Copies a numeric vector to backend-owned device memory and returns it after
#' synchronization and a device-to-host copy.
#'
#' @param values A numeric vector.
#' @param backend Backend identifier. Currently only `"cuda"` is implemented.
#' @return A numeric vector containing the copied values.
#' @export
gpu_roundtrip <- function(values, backend = gpu_backend()) {
    if (!identical(backend, "cuda")) {
        stop(sprintf("GPU backend '%s' does not support round trips", backend), call. = FALSE)
    }
    if (!is.numeric(values) || is.object(values)) {
        stop("`values` must be an ordinary numeric vector", call. = FALSE)
    }

    .Call("kitness_cuda_roundtrip", as.double(values), PACKAGE = "kitnessGpu")
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

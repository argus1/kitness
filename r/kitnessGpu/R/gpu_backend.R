#' Probe GPU backend capabilities
#'
#' Reports availability for current and planned backends through a backend-
#' neutral capability contract.
#'
#' @return A named list with entries for `"cuda"`, `"metal"`, `"rocm"`,
#'   `"oneapi"`, and `"cpu"`.
#' @export
gpu_capabilities <- function() {
    cuda <- .probe_backend_command("nvidia-smi")
    cuda_compiled <- isTRUE(.Call(
        "kitness_cuda_compiled",
        PACKAGE = "kitnessGpu"
    ))
    metal <- .probe_backend_command("xcrun", c("-f", "metal"))
    metal_compiled <- isTRUE(.Call(
        "kitness_metal_compiled",
        PACKAGE = "kitnessGpu"
    ))

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
            available = metal$available && metal_compiled,
            compiled = metal_compiled,
            status = if (metal$available && metal_compiled) "available" else "unavailable",
            detail = if (!metal_compiled) "Metal bridge was not compiled" else metal$detail
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
        ),
        cpu = list(
            backend = "cpu",
            available = TRUE,
            status = "available",
            detail = "host-resident fallback"
        )
    )
}

#' Select the available GPU backend
#'
#' Chooses `"cuda"` when an NVIDIA runtime is available, falls back to
#' `"metal"` when the native Metal toolchain is available, and returns `"cpu"`
#' otherwise.
#'
#' @return A character string, one of `"cuda"`, `"metal"`, or `"cpu"`.
#' @export
gpu_backend <- function() {
    capabilities <- gpu_capabilities()
    if (isTRUE(capabilities$cuda$available)) {
        return("cuda")
    }
    if (isTRUE(capabilities$metal$available)) {
        return("metal")
    }
    "cpu"
}

#' Round-trip numeric values through a GPU backend
#'
#' Copies a numeric vector to backend-owned device memory and returns it after
#' synchronization and a device-to-host copy.
#'
#' @param values A numeric vector.
#' @param session Optional backend session object created with
#'   [gpu_session_open()].
#' @param backend Backend identifier. `"cuda"`, `"metal"` on macOS, and
#'   `"cpu"` are implemented.
#' @return A numeric vector containing the copied values.
#' @export
gpu_roundtrip <- function(values, session = NULL, backend = gpu_backend()) {
    if (!is.numeric(values) || is.object(values)) {
        stop("`values` must be an ordinary numeric vector", call. = FALSE)
    }

    values <- as.double(values)
    if (!is.null(session)) {
        if (!inherits(session, "kitness_gpu_session")) {
            stop("`session` must be a kitness_gpu_session", call. = FALSE)
        }
        if (!isTRUE(.Call("kitness_cuda_session_is_active", session, PACKAGE = "kitnessGpu"))) {
            stop("CUDA session is closed", call. = FALSE)
        }
        return(.Call("kitness_cuda_roundtrip_with_session", values, session, PACKAGE = "kitnessGpu"))
    }

    if (identical(backend, "cpu")) {
        return(values)
    }
    if (identical(backend, "cuda")) {
        return(.Call("kitness_cuda_roundtrip", values, PACKAGE = "kitnessGpu"))
    }
    if (identical(backend, "metal")) {
        if (!isTRUE(.Call("kitness_metal_compiled", PACKAGE = "kitnessGpu"))) {
            stop("Metal backend is unavailable: install on macOS with the Metal toolchain", call. = FALSE)
        }
        metallib_path <- system.file("metal", "kitness.metallib", package = "kitnessGpu")
        if (!nzchar(metallib_path)) {
            stop("Metal shader library is missing from the installed package", call. = FALSE)
        }
        return(.Call("kitness_metal_roundtrip", values, metallib_path, PACKAGE = "kitnessGpu"))
    }

    stop(sprintf("GPU backend '%s' does not support round trips", backend), call. = FALSE)
}

#' Open a backend session handle
#'
#' Creates a backend-owned session represented as an external pointer with a
#' registered finalizer.
#'
#' @param backend Backend identifier. Currently only `"cuda"` is implemented.
#' @return An external pointer session handle.
#' @export
gpu_session_open <- function(backend = gpu_backend()) {
    if (!identical(backend, "cuda")) {
        stop(sprintf("Backend '%s' does not support sessions", backend), call. = FALSE)
    }

    session <- .Call("kitness_cuda_session_create", PACKAGE = "kitnessGpu")
    attr(session, "backend") <- "cuda"
    class(session) <- c("kitness_gpu_session", class(session))
    reg.finalizer(session, .cuda_session_finalizer, onexit = TRUE)
    session
}

#' Close a backend session handle
#'
#' @param session A session handle created with [gpu_session_open()].
#' @return Invisibly returns `TRUE`.
#' @export
gpu_session_close <- function(session) {
    if (!inherits(session, "kitness_gpu_session")) {
        stop("`session` must be a kitness_gpu_session", call. = FALSE)
    }

    .Call("kitness_cuda_session_destroy", session, PACKAGE = "kitnessGpu")
    invisible(TRUE)
}

#' Return the backend associated with a session
#'
#' @param session A session handle created with [gpu_session_open()].
#' @return Backend name.
#' @export
gpu_session_backend <- function(session) {
    if (!inherits(session, "kitness_gpu_session")) {
        stop("`session` must be a kitness_gpu_session", call. = FALSE)
    }
    attr(session, "backend")
}

.cuda_session_finalizer <- function(session) {
    .Call("kitness_cuda_session_destroy", session, PACKAGE = "kitnessGpu")
    invisible(NULL)
}

#' Report backend scaffold TODO interfaces
#'
#' Returns non-executing scaffold points for unavailable backends.
#'
#' @param backend Backend identifier. Supported values are `"rocm"` and
#'   `"oneapi"`.
#' @return A list describing planned interface entry points.
#' @export
gpu_backend_todo <- function(backend) {
    if (!is.character(backend) || length(backend) != 1L) {
        stop("`backend` must be a single backend name", call. = FALSE)
    }

    if (identical(backend, "rocm")) {
        return(list(
            backend = "rocm",
            supported = FALSE,
            interfaces = c("initialize", "allocate", "copy", "stream", "launch", "error")
        ))
    }

    if (identical(backend, "oneapi")) {
        return(list(
            backend = "oneapi",
            supported = FALSE,
            interfaces = c("queue", "usm_or_buffer", "copy", "synchronize", "dispatch", "error")
        ))
    }

    stop(sprintf("Backend '%s' has no TODO scaffold", backend), call. = FALSE)
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

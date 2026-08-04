backend <- kitnessGpu::gpu_backend()

if (!identical(backend, "metal")) {
    stop("A Metal backend is required for this workflow.", call. = FALSE)
}

message("Running a Metal-capable workflow.")

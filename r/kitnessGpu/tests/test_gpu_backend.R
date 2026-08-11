library(kitnessGpu)

backend <- gpu_backend()
stopifnot(backend %in% c("cuda", "metal", "cpu"))

capabilities <- gpu_capabilities()
stopifnot(identical(names(capabilities), c("cuda", "metal", "rocm", "oneapi", "cpu")))
stopifnot(is.logical(capabilities$cuda$compiled), length(capabilities$cuda$compiled) == 1L)

for (name in names(capabilities)) {
	entry <- capabilities[[name]]
	stopifnot(identical(entry$backend, name))
	stopifnot(is.logical(entry$available), length(entry$available) == 1L)
	stopifnot(is.character(entry$status), length(entry$status) == 1L)
}

cpu_values <- c(1.5, -2, 0, 42.25)
cpu_result <- gpu_roundtrip(cpu_values, backend = "cpu")
stopifnot(is.double(cpu_result), identical(cpu_result, cpu_values))

nvidia_smi <- Sys.which("nvidia-smi")
if (nzchar(nvidia_smi) && isTRUE(capabilities$cuda$compiled)) {
	stopifnot(identical(backend, "cuda"))
	stopifnot(isTRUE(capabilities$cuda$compiled))

	values <- c(1.5, -2, 0, 42.25)
	stopifnot(identical(gpu_roundtrip(values, backend = "cuda"), values))
} else {
	message("Skipping CUDA round-trip smoke test: native bridge or runtime unavailable")
}

xcrun <- Sys.which("xcrun")
if (!nzchar(nvidia_smi) && nzchar(xcrun)) {
	stopifnot(identical(backend, "metal"))
}

stopifnot(identical(capabilities$rocm$status, "stub"))
stopifnot(identical(capabilities$oneapi$status, "stub"))
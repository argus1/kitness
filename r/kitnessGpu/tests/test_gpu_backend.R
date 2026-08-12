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

unsupported_error <- tryCatch(
	gpu_roundtrip(cpu_values, backend = "oneapi"),
	error = conditionMessage
)
stopifnot(grepl("does not support round trips", unsupported_error, fixed = TRUE))

metal_error <- tryCatch(
	gpu_roundtrip(cpu_values, backend = "metal"),
	error = conditionMessage
)
stopifnot(grepl("Metal backend is unavailable", metal_error, fixed = TRUE))

nvidia_smi <- Sys.which("nvidia-smi")
if (nzchar(nvidia_smi) && isTRUE(capabilities$cuda$compiled)) {
	stopifnot(identical(backend, "cuda"))
	stopifnot(isTRUE(capabilities$cuda$compiled))

	session <- gpu_session_open("cuda")
	stopifnot(inherits(session, "kitness_gpu_session"))
	stopifnot(identical(gpu_session_backend(session), "cuda"))

	values <- c(1.5, -2, 0, 42.25)
	stopifnot(identical(gpu_roundtrip(values, backend = "cuda"), values))
	stopifnot(identical(gpu_roundtrip(values, session = session), values))

	gpu_session_close(session)
	error <- tryCatch(
		gpu_roundtrip(values, session = session),
		error = conditionMessage
	)
	stopifnot(grepl("CUDA session is closed", error, fixed = TRUE))
} else {
	message("Skipping CUDA round-trip smoke test: native bridge or runtime unavailable")
}

xcrun <- Sys.which("xcrun")
if (!nzchar(nvidia_smi) && nzchar(xcrun)) {
	stopifnot(identical(backend, "metal"))
}

stopifnot(identical(capabilities$rocm$status, "stub"))
stopifnot(identical(capabilities$oneapi$status, "stub"))

rocm_todo <- gpu_backend_todo("rocm")
stopifnot(identical(rocm_todo$backend, "rocm"))
stopifnot(identical(rocm_todo$supported, FALSE))
stopifnot(all(c("initialize", "allocate", "copy", "stream", "launch", "error") %in% rocm_todo$interfaces))

oneapi_todo <- gpu_backend_todo("oneapi")
stopifnot(identical(oneapi_todo$backend, "oneapi"))
stopifnot(identical(oneapi_todo$supported, FALSE))
stopifnot(all(c("queue", "usm_or_buffer", "copy", "synchronize", "dispatch", "error") %in% oneapi_todo$interfaces))
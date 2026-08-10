library(kitnessGpu)

backend <- gpu_backend()
stopifnot(backend %in% c("cuda", "metal", "unavailable"))

capabilities <- gpu_capabilities()
stopifnot(identical(names(capabilities), c("cuda", "metal", "rocm", "oneapi")))

for (name in names(capabilities)) {
	entry <- capabilities[[name]]
	stopifnot(identical(entry$backend, name))
	stopifnot(is.logical(entry$available), length(entry$available) == 1L)
	stopifnot(is.character(entry$status), length(entry$status) == 1L)
}

nvidia_smi <- Sys.which("nvidia-smi")
if (nzchar(nvidia_smi)) {
	stopifnot(identical(backend, "cuda"))
}

xcrun <- Sys.which("xcrun")
if (!nzchar(nvidia_smi) && nzchar(xcrun)) {
	stopifnot(identical(backend, "metal"))
}

stopifnot(identical(capabilities$rocm$status, "stub"))
stopifnot(identical(capabilities$oneapi$status, "stub"))
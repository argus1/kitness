# Positron integration stub for kitnessGpu.
# TODO: read Positron-provided environment variables once standardized.
# TODO: replace this placeholder with real GPU workflow task wiring.

required_tools <- c("R", "python3", "git")

is_tool_available <- function(tool) {
    nzchar(Sys.which(tool))
}

availability <- vapply(required_tools, is_tool_available, logical(1))

message("Positron stub diagnostics:")
for (tool in required_tools) {
    status <- if (availability[[tool]]) "OK" else "MISSING"
    message(sprintf("- %s: %s", tool, status))
}

if (requireNamespace("kitnessGpu", quietly = TRUE)) {
    backend <- kitnessGpu::gpu_backend()
    message(sprintf("Backend reported by kitnessGpu: %s", backend))
} else {
    backend <- NA_character_
    message("Backend check skipped: kitnessGpu is not installed in this R library.")
    message("TODO: install from r/kitnessGpu and re-run backend validation.")
}

if (!all(availability)) {
    message("TODO: stop with actionable guidance when diagnostics fail.")
}

message("TODO: run end-to-end Positron workflow command sequence.")

\name{gpu_capabilities}
\alias{gpu_capabilities}
\title{Probe GPU Backend Capabilities}
\usage{
gpu_capabilities()
}
\value{
A named list with entries for \code{"cuda"}, \code{"metal"}, \code{"rocm"},
\code{"oneapi"}, and \code{"cpu"}. Each entry provides a backend name,
availability, status, and detail string. The CUDA and ROCm entries also report
whether their native bridges were compiled.
}
\description{
Reports backend availability through a backend-neutral capability contract,
including an unavailable stub entry for planned oneAPI support.
}
\examples{
gpu_capabilities()
}

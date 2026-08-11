\name{gpu_capabilities}
\alias{gpu_capabilities}
\title{Probe GPU Backend Capabilities}
\usage{
gpu_capabilities()
}
\value{
A named list with entries for \code{"cuda"}, \code{"metal"}, \code{"rocm"}, and
\code{"oneapi"}, and \code{"cpu"}. Each entry provides backend name, availability, status, and
a detail string. The CUDA entry also reports whether the native bridge was
compiled.
}
\description{
Reports backend availability through a backend-neutral capability contract,
including unavailable stub entries for planned ROCm and oneAPI support.
}
\examples{
gpu_capabilities()
}

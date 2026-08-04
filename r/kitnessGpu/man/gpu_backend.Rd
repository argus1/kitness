\name{gpu_backend}
\alias{gpu_backend}
\title{Select the Available GPU Backend}
\usage{
gpu_backend()
}
\value{
A character string: \code{"metal"} when the native Metal compiler is available,
or \code{"unavailable"} otherwise.
}
\description{
Detects the Metal compiler through the macOS developer toolchain. CUDA support
is intentionally deferred until an NVIDIA-capable platform is available.
}
\examples{
gpu_backend()
}
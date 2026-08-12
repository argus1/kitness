\name{gpu_backend}
\alias{gpu_backend}
\title{Select the Available GPU Backend}
\usage{
gpu_backend()
}
\value{
A character string: \code{"cuda"} when an NVIDIA runtime is available,
\code{"metal"} when the Metal toolchain is available, \code{"rocm"} when a
compiled HIP bridge can access an AMD GPU, otherwise \code{"cpu"}.
}
\description{
Chooses the preferred backend from a backend-neutral capability contract,
prioritizing CUDA, Metal, ROCm, and CPU fallback.
}
\examples{
gpu_backend()
}
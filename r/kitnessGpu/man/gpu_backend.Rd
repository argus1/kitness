\name{gpu_backend}
\alias{gpu_backend}
\title{Select the Available GPU Backend}
\usage{
gpu_backend()
}
\value{
A character string: \code{"cuda"} when an NVIDIA runtime is available,
\code{"metal"} when the native Metal toolchain is available, or
\code{"unavailable"} otherwise.
}
\description{
Chooses the preferred backend from a backend-neutral capability contract,
prioritizing CUDA over Metal when both are available.
}
\examples{
gpu_backend()
}
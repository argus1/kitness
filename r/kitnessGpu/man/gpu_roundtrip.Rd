\name{gpu_roundtrip}
\alias{gpu_roundtrip}
\title{Round-Trip Numeric Values Through a GPU Backend}
\usage{
gpu_roundtrip(values, backend = gpu_backend())
}
\arguments{
\item{values}{A numeric vector.}
\item{backend}{Backend identifier. Currently only \code{"cuda"} is implemented.}
}
\value{
A numeric vector containing the copied values.
}
\description{
Copies a numeric vector to backend-owned device memory and returns it after
synchronization and a device-to-host copy.
}
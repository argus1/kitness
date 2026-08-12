\name{gpu_roundtrip}
\alias{gpu_roundtrip}
\title{Round-Trip Numeric Values Through a GPU Backend}
\usage{
gpu_roundtrip(values, session = NULL, backend = gpu_backend())
}
\arguments{
\item{values}{A numeric vector.}
\item{session}{Optional backend session object created with \code{gpu_session_open()}.}
\item{backend}{Backend identifier. \code{"cuda"}, \code{"rocm"}, and \code{"cpu"} are implemented.}
}
\value{
A numeric vector containing the copied values.
}
\description{
Copies a numeric vector to backend-owned device memory and returns it after
synchronization and a device-to-host copy.
}
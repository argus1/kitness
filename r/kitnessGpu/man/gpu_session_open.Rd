\name{gpu_session_open}
\alias{gpu_session_open}
\title{Open a Backend Session Handle}
\usage{
gpu_session_open(backend = gpu_backend())
}
\arguments{
\item{backend}{Backend identifier. \code{"cuda"} and \code{"rocm"} are implemented.}
}
\value{
An external pointer session handle.
}
\description{
Creates a backend-owned session represented as an external pointer with a
registered finalizer.
}

\name{gpu_backend_todo}
\alias{gpu_backend_todo}
\title{Report Backend Scaffold TODO Interfaces}
\usage{
gpu_backend_todo(backend)
}
\arguments{
\item{backend}{Backend identifier. Supported values are \code{"rocm"} and \code{"oneapi"}.}
}
\value{
A list describing planned interface entry points.
}
\description{
Returns non-executing scaffold points for unavailable backends.
}

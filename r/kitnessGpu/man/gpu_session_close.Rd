\name{gpu_session_close}
\alias{gpu_session_close}
\title{Close a Backend Session Handle}
\usage{
gpu_session_close(session)
}
\arguments{
\item{session}{A session handle created with \code{gpu_session_open()}.}
}
\value{
Invisibly returns \code{TRUE}.
}
\description{
Releases native backend resources for a session handle.
}

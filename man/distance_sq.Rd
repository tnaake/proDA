% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_distance.R
\name{distance_sq}
\alias{distance_sq}
\title{Square distance between two Gaussian distributions}
\usage{
distance_sq(mu1, sigma1, mu2, sigma2)
}
\value{
a list with elements `mean` and `var`

1. Mathai, A. & Provost, S. Quadratic Forms in Random Variables. (1992).
}
\description{
The function takes the mean and the diagonal of the covariance matrix
as vector and calculates the mean and variance of their distance distribution.
The formulas are based on [1] page 53.
}
\keyword{internal}

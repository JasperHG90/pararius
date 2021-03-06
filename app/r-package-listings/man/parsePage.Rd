% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{parsePage}
\alias{parsePage}
\title{Parse page}
\usage{
parsePage(req)
}
\arguments{
\item{req}{request returned by 'requestPage()'}
}
\value{
data frame containing 6 columns (name, url, new listing, agent, price, price inclusive?) of parsed listing information
}
\description{
Extract all relevant listing information from the page.
}

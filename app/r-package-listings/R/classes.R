# Classes go here

#' Aggregator class
#'
#' The aggregator class is a superclass that contains the Pararius & Funda classes
#'
#' @slot city city you want to look for listings
#' @slot min_price minimum price for the listing
#' @slot max_price maximum price for the listing
#' @slot blacklist list of realtors to blacklist
#'
#' @name Aggregator-class
.Aggregator <- setCLass("Aggregator",
                        slots = c(
                          city = "character",
                          min_price = "numeric",
                          max_price = "numeric",
                          blacklist = "list"
                        ))

#' Pararius class
#'
#' This class is used to scrape the Pararius website
#'
#' @slot search_url search url constructed for the user
#' @slot base_url root url of the aggregator
#'
#' @name Pararius-class
.Pararius <- setClass("Pararius",
                      contains = "Aggregator",
                      slots = c(
                        search_url = "character",
                        base_url = "character"
                      ))

#' Initiate an object of class Pararius
#'
#' @param city city you want to look for listings
#' @param min_price minimum price for the listing
#' @param max_price maximum price for the listing
#' @param blacklist list of realtors to blacklist
#'
#' @rdname Pararius-class
#' @export
Pararius <- function(city,
                     min_price,
                     max_price,
                     blacklist = list()) {

  ## Create search url
  su <- searchUrl("pararius", city, min_price, max_price)

  ## Initiate class
  .Pararius(
    city = city,
    min_price = min_price,
    max_price = max_price,
    blacklist = blacklist,
    search_url = su,
    base_url = "https://www.pararius.nl"
  )

}

#' Funda class
#'
#' This class is used to scrape the Funda website
#'
#' @slot search_url search url constructed for the user
#' @slot base_url root url of the aggregator
#'
#' @name Funda-class
.Funda <- setClass("Funda",
                      contains = "Aggregator",
                      slots = c(
                        search_url = "character",
                        base_url = "character"
                      ))

#' Initiate an object of class Funda
#'
#' @param city city you want to look for listings
#' @param min_price minimum price for the listing
#' @param max_price maximum price for the listing
#' @param blacklist list of realtors to blacklist
#'
#' @rdname Funda-class
#' @export
Funda <- function(city,
                     min_price,
                     max_price,
                     blacklist = list()) {

  ## Create search url
  su <- searchUrl("funda", city, min_price, max_price)

  ## Initiate class
  .Funda(
    city = city,
    min_price = min_price,
    max_price = max_price,
    blacklist = blacklist,
    search_url = su,
    base_url = "https://www.funda.nl"
  )

}

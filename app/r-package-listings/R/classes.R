# Classes go here

#' Pararius class
#'
#' This class is used to scrape the Pararius website
#'
#' @slot city city you want to look for listings
#' @slot min_price minimum price for the listing
#' @slot max_price maximum price for the listing
#' @slot bedrooms minimum amount of bedrooms for the listing
#' @slot blacklist list of realtors to blacklist
#'
#' @name Pararius-class
.Pararius <- setClass("Pararius",
                      slots = c(
                        city = "character",
                        min_price = "numeric",
                        max_price = "numeric",
                        bedrooms = "numeric",
                        blacklist = "list"
                      ))

#' Initiate an object of class Pararius
#'
#' @param city city you want to look for listings
#' @param min_price minimum price for the listing
#' @param max_price maximum price for the listing
#' @param bedrooms minimum amount of bedrooms for the listing
#' @param blacklist list of realtors to blacklist
#'
#' @importFrom stringr str_replace_all
#'
#' @rdname Pararius-class
#' @export
Pararius <- function(city,
                     min_price,
                     max_price,
                     bedrooms,
                     blacklist = list()) {

  ## Replace spaces in city name
  city <- stringr::str_replace_all(tolower(city), "\\s", "-")

  ## Make url
  if (bedrooms < 1){
    options("PARARIUS_SEARCH_URL" = paste0("https://www.pararius.nl/huurwoningen/", city, "/",
                                         min_price, "-", max_price))
  }else{
    options("PARARIUS_SEARCH_URL" = paste0("https://www.pararius.nl/huurwoningen/", city, "/",
                                         min_price, "-", max_price, "/",bedrooms,"-slaapkamers"))
  }
  

  .Pararius(
    city = city,
    min_price = min_price,
    max_price = max_price,
    bedrooms = bedrooms,
    blacklist = blacklist
  )

}

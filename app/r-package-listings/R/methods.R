# Methods go here

#' Download, parse and process new listings from an aggregator
#'
#' @param x a Pararius or Funda object
#'
#' @return a data frame containing new listings. Also saves RDS databases for proxies & listings in the current working directory.
#' @export
#'
#' @docType methods
#' @rdname update_rentals-methods
setGeneric("update_rentals", function(x) standardGeneric("update_rentals"))

#' @rdname update_rentals-methods
setMethod("update_rentals", "Pararius", function(x) {

  # Refresh proxy list
  refreshed <- refreshProxies()
  
  if(refreshed) {
    
    message("Refreshed proxy list ...")
    
  }

  # Load dat?a
  db <- loadDatabase()

  # Get listings
  req <- requestPage()

  # Parse
  parsed <- parsePage(req)

  # Filter existing
  parsed <- parsed[!(parsed$url %in% db$url),]
  
  message(paste0("Found ", nrow(parsed), " new listings ..."))

  # Add to existing
  db <- rbind(db, parsed)

  # Save
  saveRDS(db, "listings.rds")

  # Return new listings
  return(parsed)

})


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
#' 
#' @importFrom loggit loggit
setMethod("update_rentals", "Pararius", function(x) {

  # Refresh proxy list
  refreshed <- refreshProxies()
  
  if(refreshed) {
    
    loggit("INFO", "Refreshed proxy list ...")
    
  }

  # Load data
  db <- loadDatabase()
  
  if(nrow(db) == 0) {
    
    loggit("INFO", "This is your first run! How exciting. Initialized a new database to hold listings ...")
    
  }

  # Get listings
  req <- requestPage()

  # Parse
  parsed <- parsePage(req)

  # Filter existing
  parsed <- parsed[!(parsed$url %in% db$url),]
  
  loggit("INFO", paste0("Found ", nrow(parsed), " new listings ..."))

  # Add to existing
  db <- rbind(db, parsed)

  # Save
  saveRDS(db, "listings.rds")

  # Return new listings
  return(parsed)

})


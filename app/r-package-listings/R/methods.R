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
  
  # Convert dates
  if(nrow(parsed) > 0) {
    parsed$date <- as.POSIXct(parsed$date, origin = "1970-01-01")
  }
  
  # THreshold
  threshold <- 60 * 60 * 24 * 7 # sec x min x hours x days

  # Filter existing
  # Filter is:
    # Listing was posted longer than 7 days ago
    # Listing url does not yet exist in db
  # Get new listings
  new <- parsed[!(parsed$url %in% db$url),]
  # Get relistings
  relist <- parsed[parsed$url %in% db$url,]
  # If no obs
  if(nrow(relist) > 0) {
    
    # Calculate time of listing
    relist$tdiff <- difftime(Sys.time(), relist$date, units = "secs")
    # If relisting >= 7 days, also accept as 'new'
    relist <- relist[relist$tdiff >= threshold,]
    
    # Remove timediff
    relist$tdiff <- NULL
    
    # Join
    parsed <- rbind(new, relist)
    
  } else {
    
    parsed <- new
    
  }

  message(paste0("Found ", nrow(parsed), " new listings ..."))

  # Add to existing
  db <- rbind(db, parsed)

  # Save
  saveRDS(db, "listings.rds")

  # Return new listings
  return(parsed)

})


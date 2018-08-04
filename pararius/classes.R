# Classes go here 

.Pararius <- setClass("Pararius", 
                      slots = c(
                        city = "character",
                        min_price = "numeric",
                        max_price = "numeric",
                        email_to = "character",
                        blacklist = "list"
                      ))

# Constructor
Pararius <- function(city, min_price, max_price, email_to, blacklist = list()) {
  
  ## Replace spaces in city name
  city <- stringr::str_replace_all(tolower(city), "\\s", "-")
  
  ## Make url 
  options("PARARIUS_SEARCH_URL" = paste0("https://www.pararius.nl/huurwoningen/", city, "/", 
                                         min_price, "-", max_price))
  
  .Pararius(
    city = city,
    min_price = min_price,
    max_price = max_price,
    email_to = email_to,
    blacklist = blacklist
  )
  
}

## Generics ----

setGeneric("update_rentals", function(x) standardGeneric("update_rentals"))

## Methods ----

setMethod("update_rentals", "Pararius", function(x) {
  
  # Refresh proxy list 
  refreshProxies()
  
  # Load data 
  db <- loadDatabase()
  
  # Get listings 
  req <- requestPage()
    
  # Parse 
  parsed <- parsePage(req)
  
  # Filter existing 
  parsed <- parsed[!(parsed$url %in% db$url),]
  
  # Add to existing
  db <- rbind(db, parsed)
  
  # Save
  saveRDS(db, "listings.rds")
  
  # Return new listings
  return(parsed)
  
})


# Read settings
settings <- yaml::read_yaml("settings.yml")

p <- Pararius(settings$place,
              settings$min_price,
              settings$max_price,
              settings$email_to,
              list(settings$blacklist))

new <- update_rentals(p)

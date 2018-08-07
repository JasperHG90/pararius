##############################
#
# Scrape pararius new rentals
#  in The Hague and store in
#  database
#
#############################

## Libraries
library(listings)
library(loggit)

# Open log file
loggit::setLogFile("r-package-listings-logfile.json")

## Load settings
settings <- yaml::read_yaml("/root/pararius/settings.yml")

## Get environment variables
if(Sys.getenv("MAILR_HOST") == "" |
   Sys.getenv("MAILR_PORT") == "" |
   Sys.getenv("MAILR_USER") == "" |
   Sys.getenv("MAILR_PWD") == "") {

  loggit::loggit("ERROR", "One or more environment variables not found! Cannot send emails")
  stop("One or more environment variables not found! Cannot send emails")

}

## Initialize
p <- Pararius(settings$place,
              settings$min_price,
              settings$max_price,
              list(settings$blacklist))

## Scrape results, filter & store in database
new <- update_rentals(p)

# If not null

if(nrow(new) > 0) {

   ## New listings will be sent as mail
   msg <- paste0(
     '<html>',
     '<body>',
     '<p>Hi there! I found one or more new listings in ', settings$place, ' you might find iteresting!</p>',
     '<br>',
     '<div>',
     paste0(
       '<ul>',
       '<li>',
       '<p>url: ',new$url, '</p>',
       '</li>',
       '<li>',
       '<p>name: ',new$name, '</p>',
       '</li>',
       '<li>',
       '<p>realtor: ',new$agent, '</p>',
       '</li>',
       '<li>',
       '<p>price: ',new$price, ' (', ifelse(new$inclusive, "inclusive", "exclusive"),')', '</p>',
       '</li>',
       '</ul>',
       collapse = "<br>"
     ),
     '</div>',
     '</body>',
     '</html>'
   )
   
   
   
   

}


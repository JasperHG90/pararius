##############################
#
# Scrape pararius new rentals
#  in The Hague and store in
#  sqlite database
#
#############################

## Libraries
library(listings)
library(mailR)
library(loggit)

# Open log file 
loggit::setLogFile("~/r-package-listings-logfile.json")

## Load settings
settings <- yaml::read_yaml("settings.yml")

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
  
  ## Mail new results 
  send.mail(from = settings$email_from,
            to = settings$email_to,
            subject = "New listings found!",
            body = msg,
            html = TRUE,
            inline = TRUE,
            smtp = list(host.name = Sys.getenv("MAILR_HOST"), 
                        port = Sys.getenv("MAILR_PORT"), 
                        user.name = Sys.getenv("MAILR_USER"), 
                        passwd = Sys.getenv("MAILR_PWD"), 
                        ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
}


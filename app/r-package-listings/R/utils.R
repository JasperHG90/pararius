# Utility functions go here

#' Load database if exists
#'
#' @return If the database 'listings.rds' exists, the function returns this database. Else, it will return an empty tibble containing the same columns.
#'
#' @importFrom tibble data_frame
loadDatabase <- function() {

  if(file.exists("listings.rds")) {

    readRDS("listings.rds")

  } else {

    data_frame(
      "name" = character(),
      "url" = character(),
      "new" = logical(),
      "agent" = character(),
      "price" = double(),
      "inclusive" = logical()
    )

  }

}

#' Download and save a list of proxies
#'
#' This function downloads a fresh list of https proxies every 24 hours. This is necessary to load the Pararius/Funda websites because they have good anti-scraping protection.
#'
#' @return TRUE if new proxy list has been downloaded. FALSE if not.
#'
#' @importFrom xml2 read_html
#' @importFrom magrittr '%>%'
#' @importFrom rvest html_node
#' @importFrom rvest html_table
refreshProxies <- function() {

  # Now
  dt <- Sys.time()

  # Load last update
  if("last_proxy_update.rds" %in% list.files()) {

    last <- readRDS("last_proxy_update.rds")

    # Do not refresh if less then 24 hours ago
    if(difftime(dt, last, units = "days") < 1) {

      return(FALSE)

    }

  }

  # Retrieve list of proxy addresses
  proxy_addresses <- 'https://free-proxy-list.net/'

  # Get max pages
  page <- read_html(proxy_addresses)

  # Proxies
  proxies <- page %>%
    html_node(css = "#proxylisttable") %>%
    html_table()

  # Filter for https
  proxies <- proxies[proxies$Https == 'yes', ]

  # Select columns
  proxies <- proxies[,c(1, 2, 3)]

  # Rename columns
  colnames(proxies) <- c("address", "port", "country")

  # Save date
  saveRDS(proxies, "proxies.rds")

  # Save date last saved
  saveRDS(dt, "last_proxy_update.rds")

  # Return true
  return(TRUE)

}

#' Sample a random proxy address
#'
#' This function takes the list of proxies and randomly samples one of the addresses. The list can be filtered for proxies that were already tried but failed.
#'
#' @param proxies data frame containing proxy addresses and ports. Returned by 'refreshProxies()' function
#' @param filter vector containing addresses of proxies that were already tried but failed to resolve.
#'
#' @return named vector where: the value is the port and the name is the proxy address
getProxy <- function(proxies, filter = c()) {

  # Convenience function to subset a proxy
  subsetproxy <- function(proxies) {

    # Sample
    row <- sample(1:nrow(proxies), 1)
    # Get
    proxy <- proxies[row, ]
    fp <- proxy$port
    names(fp) <- proxy$address
    # Return
    return(fp)

  }

  if(length(filter) != 0) {
    # Filter
    proxies <- proxies[!proxies$address %in% filter,]
  }

  # Subset one
  subsetproxy(proxies)

}

#' Request page
#'
#' This function loads the Pararius/Funda page.
#'
#' @return httr request information if successful. Raises error if unsuccessful.
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr use_proxy
#' @importFrom httr verbose
#' @importFrom httr timeout
#' @importFrom httr http_error
requestPage <- function() {

  # Read data
  proxies <- readRDS("proxies.rds")

  # Make filter
  filter <- c()

  # Get proxy
  proxy <- getProxy(proxies, filter = filter)

  tries <- 1
  success <- FALSE
  while(success == FALSE & (tries <= nrow(proxies))) {

    cat("\n")
    cat(paste0("TRY NUMBER ", tries, "\n"))
    cat(paste0("USING PROXY '", names(proxy), "'"))
    cat("\n")

    # Request page
    req <- tryCatch({

      # Get webpage using a public proxy
      GET(getOption("PARARIUS_SEARCH_URL"),
          use_proxy(names(proxy), unname(proxy)),
          verbose(),
          timeout(10),
          add_headers(getOption("PARARIUS_HEADERS")))

    }, error = function(e) {

      NULL

    })

    # If null, then failed
    if(is.null(req)) {

      if(tries == length(getOption("PARARIUS_PROXIES"))) {
        message("Max retries reached. None of the proxies worked!")
        stop("Max retries reached. None of the proxies worked!")
      }

      # Append filter with current proxy
      filter <- c(filter, names(proxy))

      # Get new proxy
      proxy <- getProxy(proxies, filter = filter)

      # Add 1 to number of tries
      tries <- tries + 1

    } else {

      # Check if errored
      if(httr::http_error(req)) {

        tries <- tries + 1

        next

      } else {

        message(paste0("Succeeded in scraping Pararius after ", tries, " tries."))

        return(req)

      }

    }

  }

}

#' Parse page
#'
#' Extract all relevant listing information from the page.
#'
#' @param req request returned by 'requestPage()'
#'
#' @return data frame containing 6 columns (name, url, new listing, agent, price, price inclusive?) of parsed listing information
#' @importFrom xml2 read_html
#' @importFrom magrittr '%>%'
#' @importFrom rvest html_node
#' @importFrom rvest html_table
#' @importFrom rvest html_text
#' @importFrom rvest html_nodes
#' @importFrom stringr str_replace_all
#' @importFrom rvest html_attr
#' @importFrom stringr str_split
#' @importFrom stringr str_detect
#' @importFrom tibble as.tibble
parsePage <- function(req) {

  # Read result
  res <- read_html(req) %>%
    html_node(xpath = '//*[@id="search-page"]/div/div')

  # Count
  count <- res %>%
    html_node(css = "div.header") %>%
    html_node(css = "p.count") %>%
    html_text() %>%
    stringr::str_replace_all("\\n", "") %>%
    trimws()

  ## Log count

  # Get results
  apartments <- res %>%
    html_node(css = "ul.search-results-list") %>%
    html_nodes(css = "li.property-list-item-container") %>%
    lapply(function(x) {

      tmp <- x %>%
        html_node(css = "div.details")

      # Name + url
      meta <- tmp %>%
        html_node("h2") %>%
        html_node("a")

      name <- meta %>% html_text() %>%
        stringr::str_replace_all("\\n", "") %>%
        trimws()

      url <- meta %>% html_attr("href")

      is_new <- tmp %>% html_node(css = "span.new")

      if(length(is_new) == 0) {
        is_new <- FALSE
      } else {
        is_new <- TRUE
      }

      agent <- tmp %>% html_node(css = "p.estate-agent") %>%
        html_text() %>%
        stringr::str_replace_all("\\n", "") %>%
        trimws() %>%
        stringr::str_split(":\\s") %>%
        .[[1]] %>%
        .[2] %>%
        trimws()

      price <- tmp %>%
        html_node(css = "p.price") %>%
        html_text() %>%
        stringr::str_replace_all("\\n", "") %>%
        trimws()

      inclusive <- price %>%
        stringr::str_detect("incl")

      price <- price %>%
        stringr::str_replace_all("[^0-9]", "") %>%
        as.numeric()

      # Return
      list(
        name = name,
        url = url,
        new = is_new,
        agent = agent,
        price = price,
        inclusive = inclusive
      )

    }) %>%
    do.call(rbind.data.frame, .)

  # Change types
  apartments$name <- as.character(apartments$name)
  apartments$url <- as.character(apartments$url)
  apartments$agent <- as.character(apartments$agent)

  # Return
  return(as.tibble(apartments))

}

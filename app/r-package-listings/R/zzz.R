# Load on startup

# When the package is loaded, do ...
.onLoad <- function(libname = find.package("listings"), pkgname="listings") {
  
  # Log
  message("package loaded ...")

  # Headers
  options("PARARIUS_HEADERS" = c(
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36',
    'Connection' = 'keep-alive',
    'Accept-Language' = 'en-GB,en;q=0.8,zh-CN;q=0.6,zh;q=0.4,en-US;q=0.2,fr;q=0.2,zh-TW;q=0.2',
    'Accept-Encoding' = 'gzip, deflate, br',
    'Accept' = '*/*',
    'Accept-Charset' = 'GBK,utf-8;q=0.7,*;q=0.3',
    'Cache-Control' = 'max-age=0'
    )
  )

}

# When the package is unloaded, do
.onUnload <- function(libname = find.package("listings"), pkgname="listings") {
  
  message("package unloaded ...")
  
}
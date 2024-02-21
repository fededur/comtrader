#' countryshiny
#'
#' @description Named list of country codes to use in comtrader shiny app.
#' @details The list includes a "World" code in addition to M49 codes for individual countries.
#' @docType data
#' @name countryshiny
#' @format
#' \describe{
#'   \item{List name}{country description.}
#'   \item{List item}{country code}
#' }
#' @source ARIA
#' @import dplyr
#' @export
"countryshiny" <- as.list(setNames(read.csv("data/countrycodes.csv", check.names = F, stringsAsFactors = F) %>%
                                     pull(code),
                                   read.csv("data/countrycodes.csv", check.names = F, stringsAsFactors = F) %>%
                                     pull(descriptor)))

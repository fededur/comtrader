#' Get meta data from UN Comtrade Database API
#'
#' @description Query meta data in the UN Comtrade API
#' @details further details on API features available at: `https://comtradedeveloper.un.org/api-details#api=comtrade-v1`
#' @param typeCode Type of trade: C for commodities and S for service
#' @param freqCode Trade frequency: A for annual and M for monthly
#' @param clCode Trade (IMTS) classifications: HS, SITC, BEC or EBOPS.
#'
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @examples
#' getMetadata(clCode = "H6")
getMetadata <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS"){

  formals_list <- mget(names(formals()), sys.frame(sys.nframe()))

  null_formals <- names(formals_list)[sapply(formals_list, is.null)]

  formals_list <- formals_list[!names(formals_list) %in% c(null_formals,"key")]

  domain_list <- formals_list[names(formals_list) %in% c("typeCode","freqCode","clCode")]

  domain_string <- paste0(domain_list, collapse = "/")

  res <- httr::GET(
    url = paste0("https://comtradeapi.un.org/data/v1/getMetadata/",domain_string),
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res) %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}

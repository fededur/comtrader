#' Get metadata from UN Comtrade Database API
#'
#' @description Query meta data from the UN Comtrade API
#' @details further details on API features available at: `https://comtradedeveloper.un.org/api-details#api=comtrade-v1`.
#' @param typeCode a character string indicating type of trade: "C" for commodities and "S" for service
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param clCode a character string indicating trade classification (IMTS): "HS", "SITC", "BEC" or "EBOPS"
#' @return a tibble.
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

  if(is.null(comtrader::get_uncomtrade_key())){

    stop("Use set_uncomtrade_key() to set UN Comtrade API access key")

  }

  formals_list <- mget(names(formals()), sys.frame(sys.nframe()))

  null_formals <- names(formals_list)[sapply(formals_list, is.null)]

  formals_list <- formals_list[!names(formals_list) %in% c(null_formals,"key")]

  domain_list <- formals_list[names(formals_list) %in% c("typeCode","freqCode","clCode")]

  domain_string <- paste0(domain_list, collapse = "/")

  res <- httr::GET(
    url = paste0("https://comtradeapi.un.org/data/v1/getMetadata/",domain_string),
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}

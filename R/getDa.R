#' Get dataset availability from UN Comtrade Database API
#'
#' @description Query datasets available in the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
#' @param typeCode a character string indicating type of trade: "C" for commodities and "S" for service
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param clCode a character string indicating trade classification (IMTS): "HS", "SITC", "BEC" or "EBOPS"
#' @param reporterCode a character string indicating reporter code (Possible values are M49 code of the countries)
#' @param period a character string indicating period. Year ("YYYY") or yearmonth ("YYYYMM"). Use character vector for multiple periods (defaults to all)
#' @param publishedDateFrom a character string indicating the start publication date ("YYYY-MM-DD")
#' @param publishedDateTo a character string indicating the end publication date ("YYYY-MM-DD")
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @examples
#' getDa(clCode = "H6", publishedDateFrom = "2020-01-01")
getDa <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS",
    reporterCode = NULL,
    period = NULL,
    publishedDateFrom,
    publishedDateTo){

  if(is.null(get_uncomtrade_key())){

    warning("API key is not set. Please use set_uncomtrade_key() to set your API key to access the data.")
    return(NULL)

  }

  formals_list <- mget(names(formals()), sys.frame(sys.nframe()))

  null_formals <- names(formals_list)[sapply(formals_list, is.null)]

  formals_list <- formals_list[!names(formals_list) %in% c(null_formals,"key")]

  domain_list <- formals_list[names(formals_list) %in% c("typeCode","freqCode","clCode")]

  query_list <- formals_list[!names(formals_list) %in% names(domain_list)]

  query_list <- lapply(query_list, function(x) paste0(x, collapse = ","))

  domain_string <- paste0(domain_list, collapse = "/")

  query_string <- paste0(names(query_list), "=", query_list, collapse = "&")

  res <- httr::GET(
    url = paste0("https://comtradeapi.un.org/data/v1/getDa/",domain_string,"?",query_string),
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}

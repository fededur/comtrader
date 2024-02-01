#' Get dataset availability from UN Comtrade Database API
#'
#' @description Query datasets available in the UN Comtrade API
#' @details further details on API features available at: `https://comtradedeveloper.un.org/api-details#api=comtrade-v1`
#' @param typeCode Type of trade: C for commodities and S for service
#' @param freqCode Trade frequency: A for annual and M for monthly
#' @param clCode Trade (IMTS) classifications: HS, SITC, BEC or EBOPS.
#' @param reporterCode Reporter code (Possible values are M49 code of the countries separated by comma (,))
#' @param period Year or month. Year should be 4 digit year. Month should be six digit integer with the values of the form YYYYMM. Ex: 201002 for 2010 February. Multi value input should be in the form of csv (Codes separated by comma (,))
#' @param publishedDateFrom Publication date From YYYY-MM-DD
#' @param publishedDateTo Publication date To YYYY-MM-DD
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @examples
#' getDagetDa(clCode = "H6",publishedDateFrom = "2020-01-01")
getDa <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS",
    reporterCode = NULL,
    period = NULL,
    publishedDateFrom,
    publishedDateTo){

  if(is.null(comtrader::get_uncomtrade_key())){

    stop("Use set_uncomtrade_key() to set UN Comtrade API access key")

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

  dt <- httr::content(res) %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}

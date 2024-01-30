#' Custom get data from UN Comtrade Database API
#'
#' @description Custom get function to query data from the UN Comtrade API.
#' @details further details on API features available at: `https://comtradedeveloper.un.org/api-details#api=comtrade-v1&operation=get-get`
#' @param typeCode Type of trade: C for commodities and S for service
#' @param freqCode Trade frequency: A for annual and M for monthly
#' @param clCode Trade (IMTS) classifications: HS, SITC, BEC or EBOPS.
#' @param reporterCode Reporter code (Possible values are M49 code of the countries)
#' @param startDate Optional start date for query (e.g. "2020-01-01"). Multi value input should be in the form of a character vector.
#' @param endDate Optional end date for query (e.g. "2022-01-01").
#' @param partnerCode Partner code (Possible values are M49 code of the countries)
#' @param partner2Code Second partner/consignment code (Possible values are M49 code of the countries)
#' @param cmdCode Commodity code. Multi value input should be in the form of a character vector.
#' @param flowCode Trade flow code. Multi value input should be in the form of a character vector)
#' @param customsCode Customs code. Multi value input should be in the form of a character vector)
#' @param motCode Mode of transport code. Multi value input should be in the form of a character vector)
#' @param aggregateBy Add parameters in the form of a character vector on which you want the results to be aggregated
#' @param breakdownMode Mode to choose from
#' @param includeDesc Include descriptions of data variables
#' @return a tibble
#'
#' @import httr dplyr lubridate
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @export
#' @examples
#' getUNComtrade(freqCode = "M",cmdCode = "010129" ,reporterCode = 36, startDate = c("2020-01-01"),endDate = "2020-02-01")
getUNComtrade <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS",
    reporterCode = NULL,
    startDate = NULL,
    endDate = NULL,
    partnerCode = NULL,
    partner2Code = NULL,
    cmdCode = NULL,
    flowCode = NULL,
    customsCode = NULL,
    motCode = NULL,
    aggregateBy = NULL,
    breakdownMode = "classic",
    includeDesc = TRUE){

  nullToChr <- function(x) if(is.null(x)) NULL else if(!is.null(x))  paste0(x, collapse = ",")

  formatDate <- function(date, freqCode) {

    ords <- c("%Y%m", "%Y%m%d", "%d%m%Y", "%Y")

    date <- lubridate::parse_date_time(date, orders = ords)

    fmt <- if(freqCode == "M") "%Y%m" else "%Y"

    formatted_dates <- format(date, fmt)

    return(formatted_dates)
  }

  period_fmt <- if(!is.null(startDate) && !is.null(endDate)){
    seq(lubridate::ymd(startDate), lubridate::ymd(endDate), by = "months") %>%
      map_chr(~formatDate(.x, freqCode)) %>%
      nullToChr()
  } else {
    formatDate(startDate, freqCode) %>%
      nullToChr()
  }

  url <-  paste0("https://comtradeapi.un.org/data/v1/get/",typeCode,"/",freqCode,"/",clCode,"?")
  res <- httr::GET(
    url = url,
    query = list(
      reporterCode = nullToChr(reporterCode),
      period = period_fmt,
      partnerCode = nullToChr(partnerCode),
      partner2Code = nullToChr(partner2Code),
      cmdCode = nullToChr(cmdCode),
      flowCode = nullToChr(flowCode),
      customsCode = nullToChr(customsCode),
      motCode = nullToChr(motCode),
      aggregateBy = nullToChr(aggregateBy),
      breakdownMode = breakdownMode,
      includeDesc = includeDesc),
    add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  cat("URL:", gsub("[?]$","",url), "\n")

  cat("Status code:", httr::status_code(res), "\n")

  dt <- content(res) %>%
    purrr::pluck("data") %>%
    bind_rows()

  if(nrow(dt) == 100000) warning("dataset may be truncated")

  return(dt)
}

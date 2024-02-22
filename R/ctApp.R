#' Custom get data from UN Comtrade Database API used in comtrader::app
#'
#' @description Custom get function to query data from the UN Comtrade API used in comtrader::app.
#' @param freqCode Trade frequency: A for annual and M for monthly.
#' @param clCode Trade (IMTS) classifications: HS, SITC, BEC or EBOPS.
#' @param reporterCode Reporter code (Possible values are M49 code of the countries).
#' @param startDate Optional start date for query (e.g. "2020-01-01"). Multi value input should be in the form of a character vector.
#' @param endDate Optional end date for query (e.g. "2022-01-01").
#' @param partnerCode Partner code (Possible values are M49 code of the countries).
#' @param partner2Code Second partner/consignment code (Possible values are M49 code of the countries).
#' @param flowCode Trade flow code. Multi value input should be in the form of a character vector).
#' @param customsCode Customs code. Multi value input should be in the form of a character vector).
#' @param motCode Mode of transport code. Multi value input should be in the form of a character vector).
#' @param aggregateBy Add parameters in the form of a character vector on which you want the results to be aggregated.
#' @param breakdownMode Mode to choose from.
#' @param includeDesc Include descriptions of data variables.
#' @param sopiLevel SOPI level column in `omtcodes` (either `Primary Industry Sector` or `SOPI_group_HS6`).
#' @param sopiFilter character string to filter SOPI level (e.g.: "Dairy").
#' @param uncomtrade_key UN Comtrade API key.
#' @return a tibble
#'
#' @import httr dplyr lubridate
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @export
#' @examples
#' ctApp(freqCode = "M", reporterCode = 36, startDate = "2020-01-01", endDate = "2020-02-01", sopiLevel = `Primary Industry Sector`, sopiFilter = "Dairy", uncomtrade_key = "")
ctApp <- function(
    freqCode = "M",
    reporterCode = NULL,
    period = NULL,
    partnerCode = NULL,
    partner2Code = NULL,
    cmdCode = NULL,
    flowCode = NULL,
    customsCode = NULL,
    motCode = NULL,
    aggregateBy = NULL,
    breakdownMode = "classic",
    includeDesc = TRUE,
    uncomtrade_key){

  nullToChr <- function(x) if(is.null(x)) NULL else if(!is.null(x))  paste0(x, collapse = ",")

  url <-  paste0("https://comtradeapi.un.org/data/v1/get/C/",freqCode,"/HS?")

  uncomtrade_key <- sym(uncomtrade_key)

  res <- httr::GET(
    url = url,
    query = list(
      reporterCode = nullToChr(reporterCode),
      period =  nullToChr(unique(period)),
      partnerCode = nullToChr(partnerCode),
      partner2Code = nullToChr(partner2Code),
      cmdCode = nullToChr(cmdCode),
      flowCode = nullToChr(flowCode),
      customsCode = nullToChr(customsCode),
      motCode = nullToChr(motCode),
      aggregateBy = nullToChr(aggregateBy),
      breakdownMode = breakdownMode,
      includeDesc = includeDesc),
    httr::add_headers("Ocp-Apim-Subscription-Key" = as.character(uncomtrade_key)))

  cat("URL:", gsub("[?]$","",url), "\n")

  cat("calling ctAPP with uncomtrade_key:", uncomtrade_key, "\n")

  cat("Status code:", httr::status_code(res), "\n")

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows() #%>%
  #mutate("{{input$}}" := dplyr::recode(cmdCode, !!!sopi_descriptor))

  if(nrow(dt) == 100000) warning("dataset may be truncated")

  if(nrow(dt) == 0) cat("Your query yielded no result\n")

  return(dt)
}

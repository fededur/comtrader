#' Custom get data from UN Comtrade Database API used by `comtrader::app`
#'
#' @description Custom get function to query data from the [UN Comtrade API](`https://comtradedeveloper.un.org`) used by `comtrader::ctdashboard` Shiny app
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param reporterCode a character string indicating reporter code (M49 International Country Classification)
#' @param period a character string indicating period. Year ("YYYY") or yearmonth ("YYYYMM"). Use character vector for multiple periods (defaults to all)
#' @param partnerCode Partner code (M49 International Country Classification)
#' @param partner2Code Second partner/consignment code (M49 International Country Classification)
#' @param cmdCode a character string indicating HS commodity code. Use character vector for multiple commodity code entries (defaults to all)
#' @param flowCode a character string indicating trade flow code:  "X" for exports, "RX" for re-exports, "M" for imports, "RM" for re-imports. Use character vector for multiple trade flow entries
#' @param customsCode a character string indicating customs code. Use character vector for multiple customs code entries (defaults to all)
#' @param motCode a character string indicating mode of transport code. Use character vector for multiple transport code entries(defaults to all)
#' @param aggregateBy Add parameters in the form of a character vector on which you want the results to be aggregated
#' @param breakdownMode a character string indicating breakdown mode: "classic" (trade by partner/product: dafault) or "plus" (extended breakdown)
#' @param includeDesc boolean indicating if categories descriptions shoould be returned (defaults to `TRUE`)
#' @param uncomtrade_key a character string indicating UN Comtrade API key
#' @return a tibble
#'
#' @import httr dplyr lubridate
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @importFrom purrr pluck
#' @export
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
    bind_rows()

  msg <- paste(
    paste0("Your query: ", res[["request"]][["url"]],"&key=", res[["request"]][["headers"]][["Ocp-Apim-Subscription-Key"]]),
    paste0("Status code: ",res[["status_code"]]),
    paste0("Response: ",dplyr::case_when(
      nrow(dt) == 1e+05 ~ "dataset may be truncated",
      (ncol(dt) == 0 & nrow(dt) == 0 & res[["status_code"]] == 200) ~ "your query yield no result",
      TRUE ~ "")),
    sep="\n")

  qr <- list(
    data = dt,
    message = msg
  )

  return(qr)
}

#' Support functions
#'
#' Custom support functions for `comtrader`


#' Set package key for UNComprade API
#'
#' @param key The value to set as the key
#' @export
set_uncomtrade_key <- function(key) {
  options("key" = key)
}


#' Get package key for UNComprade API
#'
#' @return The value of the key
#' @export
get_uncomtrade_key <- function() {
  getOption("key", default = NULL)
}


#' Custom get data from UN Comtrade Database API used by `comtrader::ctdashboard`
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


#' Custom get data from UN Comtrade Database API
#'
#' @description Custom get function to query data from the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
#' @param typeCode a character string indicating type of trade: "C" for commodities and "S" for service
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param clCode a character string indicating trade classification (IMTS): "HS", "SITC", "BEC" or "EBOPS"
#' @param reporterCode a character string indicating reporter code (Possible values are M49 code of the countries)
#' @param startDate a character string indicating start date for query: "YYYY-MM-DD" (optional).
#' @param endDate Optional end date for query: "YYYY-MM-DD" (optional).
#' @param partnerCode Partner code (M49 International Country Classification).
#' @param partner2Code Second partner/consignment code (M49 International Country Classification).
#' @param flowCode a character string indicating trade flow code:  "X" for exports, "RX" for re-exports, "M" for imports, "RM" for re-imports. Use character vector for multiple trade flow entries
#' @param customsCode a character string indicating customs code. Use character vector for multiple customs code entries (defaults to all)
#' @param motCode a character string indicating mode of transport code. Use character vector for multiple customs code entries transport code (defaults to all)
#' @param aggregateBy Add parameters in the form of a character vector on which you want the results to be aggregated
#' @param breakdownMode a character string indicating breakdown mode: "classic" (trade by partner/product: dafault) or "plus" (extended breakdown)
#' @param includeDesc boolean indicating if categories descriptions shoould be returned (defaults to `TRUE`)
#' @param sopiLevel SOPI level column in `omtcodes` (either `Primary_Industry_Sector` or `SOPI_group_HS6`)
#' @param sopiFilter character string to filter SOPI level (e.g.: "Dairy")
#' @param hs HS code level column in `omtcodes` (e.g.: `NZHSCLevel6`)
#' @return a tibble
#'
#' @import httr dplyr lubridate rlang
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @export
#' @examples
#' getCTSopi(reporterCode = 36,
#'           startDate = "2020-01-01",
#'           endDate = "2020-02-01",
#'           sopiLevel = Primary_Industry_Sector,
#'           sopiFilter = "Dairy")
getCTSopi <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS",
    reporterCode = NULL,
    startDate = NULL,
    endDate = NULL,
    partnerCode = NULL,
    partner2Code = NULL,
    flowCode = NULL,
    customsCode = NULL,
    motCode = NULL,
    aggregateBy = NULL,
    breakdownMode = "classic",
    includeDesc = TRUE,
    sopiLevel = Primary_Industry_Sector,
    sopiFilter = NULL,
    hs = NZHSCLevel6){

  if(is.null(get_uncomtrade_key())){

    warning("API key is not set. Please use set_uncomtrade_key() to set your API key to access the data.")
    return(NULL)

  }

  omtcodes <- comtrader::omtcodes

  sopiLevel_quo <-rlang::enquo(sopiLevel)

  hs_quo <- rlang::enquo(hs)

  nullToChr <- function(x) if(is.null(x)) NULL else if(!is.null(x))  paste0(x, collapse = ",")

  formatDate <- function(date, freqCode) {

    ords <- c("%Y%m", "%Y%m%d", "%d%m%Y","%Y")

    date <- lubridate::parse_date_time(date, orders = ords)

    fmt <- if(freqCode == "M") "%Y%m" else "%Y"

    formatted_dates <- format(date, fmt)

    return(formatted_dates)
  }

  by_period <- case_when(
    freqCode == "M" ~ "months",
    freqCode == "A" ~ "year"
  )

  period_fmt <- if(!is.null(startDate) && !is.null(endDate)){
    seq(lubridate::ymd(startDate), lubridate::ymd(endDate), by = by_period) %>%
      map_chr(~formatDate(.x, freqCode)) %>%
      nullToChr()
  } else {
    formatDate(startDate, freqCode) %>%
      nullToChr()
  }

  QueryCodes <- omtcodes %>%
    tibble::as_tibble() %>%
    select({{sopiLevel_quo}},{{hs_quo}}) %>%
    {if(!is.null({{sopiFilter}})) filter(.,if_all({{sopiLevel_quo}}, ~ . %in% {{sopiFilter}})) else .} %>%
    distinct()

  cmdCode <- QueryCodes %>%
    pull({{hs_quo}})

  sopi_descriptor <- QueryCodes %>%
    select({{hs_quo}},{{sopiLevel_quo}}) %>%
    tibble::deframe(.)

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
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  cat("URL:", gsub("[?]$","",url), "\n")

  cat("Status code:", httr::status_code(res), "\n")

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows() %>%
    mutate("{{sopiLevel_quo}}" := dplyr::recode(cmdCode, !!!sopi_descriptor))

  if(nrow(dt) == 100000) warning("dataset may be truncated")

  if(nrow(dt) == 0) cat("Your query yielded no result\n")

  return(dt)
}


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


#' Get tariff line data availability from UN Comtrade Database API
#'
#' @description Query tariff line data availability in the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
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
#' @importFrom purrr pluck
#' @examples
#' getDaTariffline(clCode = "H6", publishedDateFrom = "2020-01-01")
getDaTariffline <- function(
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
    url = paste0("https://comtradeapi.un.org/data/v1/getDaTariffline/",domain_string,"?",query_string),
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}


#' Get tariff line data from UN Comtrade Database API
#'
#' @description Query tariff line data in the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
#' @param typeCode a character string indicating type of trade: "C" for commodities and "S" for service
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param clCode a character string indicating trade classification (IMTS): "HS", "SITC", "BEC" or "EBOPS"
#' @param reporterCode a character string indicating reporter code (Possible values are M49 code of the countries)
#' @param period a character string indicating period. Year ("YYYY") or yearmonth ("YYYYMM"). Use character vector for multiple periods (defaults to all)
#' @param partnerCode Partner code (M49 International Country Classification)
#' @param partner2Code Second partner/consignment code (M49 International Country Classification)
#' @param cmdCode a character string indicating HS commodity code. Use character vector for multiple commodity code entries (defaults to all)
#' @param flowCode a character string indicating trade flow code:  "X" for exports, "RX" for re-exports, "M" for imports, "RM" for re-imports. Use character vector for multiple trade flow entries
#' @param customsCode a character string indicating customs code. Use character vector for multiple customs code entries (defaults to all)
#' @param motCode a character string indicating mode of transport code. Use character vector for multiple customs code entries transport code (defaults to all)
#' @param includeDesc boolean indicating if categories descriptions shoould be returned (defaults to `TRUE`)
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @importFrom purrr pluck
#' @examples
#' getTariffline(period = "202201")
getTariffline <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS",
    reporterCode = NULL,
    period = NULL,
    partnerCode = NULL,
    partner2Code = NULL,
    cmdCode = NULL,
    flowCode = NULL,
    customsCode = NULL,
    motCode = NULL,
    includeDesc = TRUE){

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
    url = paste0("https://comtradeapi.un.org/data/v1/getTariffline/",domain_string,"?",query_string),
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}


#' Get live update data from UN Comtrade Database API
#'
#' @description Query progress on data release in the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @importFrom purrr pluck
#' @examples
#' getLiveUpdate()
getLiveUpdate <- function(){

  if(is.null(get_uncomtrade_key())){

    warning("API key is not set. Please use set_uncomtrade_key() to set your API key to access the data.")
    return(NULL)

  }

  res <- httr::GET(
    url = "https://comtradeapi.un.org/data/v1/getLiveUpdate/",
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}


#' Get metadata from UN Comtrade Database API
#'
#' @description Query meta data from the UN Comtrade API
#' @details for further details visit the [UN Comtrade API developer site](`https://comtradedeveloper.un.org`)
#' @param typeCode a character string indicating type of trade: "C" for commodities and "S" for service
#' @param freqCode a character string indicating trade frequency: "A" for annual and "M" for monthly
#' @param clCode a character string indicating trade classification (IMTS): "HS", "SITC", "BEC" or "EBOPS"
#' @return a tibble.
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @importFrom purrr pluck
#' @examples
#' getMetadata(clCode = "H6")
getMetadata <- function(
    typeCode = "C",
    freqCode = "M",
    clCode = "HS"){

  if(is.null(get_uncomtrade_key())){

    warning("API key is not set. Please use set_uncomtrade_key() to set your API key to access the data.")
    return(NULL)

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


#' Identify conflicts between two categories in a table
#'
#' @description Creates a table of counts of matching categories between two columns of a table
#' @details the table is built with reference to `ref1`
#' @param x a data frame
#' @param ref1 first reference column
#' @param ref2 second reference column
#' @return a tibble
#'
#' @import dplyr tibble rlang
#' @importFrom magrittr %>%
#' @importFrom tidyr pivot_wider
#' @export
#' @examples
#' cCheck(x = comtrader::omtcodes, ref1 = NZHSCLevel4, ref2 = `SOPI_group_HS6`)
cCheck <- function(x = comtrader::omtcodes, ref1, ref2){

  x %>%
    as_tibble() %>%
    select({{ref1}}, {{ref2}}) %>%
    tidyr::pivot_wider(
      names_from = {{ref2}},
      values_from = {{ref2}},
      values_fn = ~ length(unique(.))
    ) %>%
    replace(is.na(.), 0) %>%
    group_by({{ref1}}) %>%
    mutate(
      {{ref2}} := paste0(names(cur_data()[-1])[cur_data()[-1] > 0], collapse = ", ")
    ) %>%
    ungroup() %>%
    mutate(count = rowSums(across(-c({{ref1}}, {{ref2}})), na.rm = TRUE)) %>%
    select({{ref1}}, {{ref2}}, count) %>%
    arrange(desc(count))

}


#' Create named vector for HS codes
#'
#' @description Creates a named character vector of matching HS codes and SOPI Categories
#' @details Data was extracted from the Power BI OMT dataset. This dataset needs to be updated if there are changes in the OMT classification
#' @param hsLevel NZHSC level code (either NZHSCLevel2, NZHSCLevel4 or NZHSCLevel6)
#' @param sopiLevel SOPI category level (either `Primary_Industry_Sector` or `SOPI_group_HS6`)
#' @param sopiFilter a character vector indicating SOPI category level to filter
#' @param query If `TRUE` returns a vector of commodity codes (`cmdCode`) to use in a query. If `FALSE` returns a vector of `sopiLevel` names associated with the commodity code.
#' @return a named character vector
#' @import dplyr tibble rlang
#' @importFrom magrittr %>%
#' @export
#' @examples
#' commodityRecode(hsLevel = NZHSCLevel6, sopiLevel = Primary_Industry_Sector, sopiFilter = "Dairy")
commodityRecode <-  function(hsLevel = NZHSCLevel6,
                             sopiLevel = `SOPI_group_HS6`,
                             sopiFilter = NULL,
                             query = TRUE) {

  omtcodes %>%
    tibble::as_tibble() %>%
    select({{sopiLevel}},{{hsLevel}}) %>%
    {if(!is.null({{sopiFilter}})) filter(.,if_all({{sopiLevel}}, ~ . %in% {{sopiFilter}})) else .} %>%
    distinct() %>%
    {if(isTRUE({{query}})){
      tibble::deframe(.)
    } else if(isFALSE({{query}})) {
      select(.,{{hsLevel}},{{sopiLevel}}) %>%
        tibble::deframe()
    }
    }
}

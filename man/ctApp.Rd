% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/support-functions.R
\name{ctApp}
\alias{ctApp}
\title{Custom get data from UN Comtrade Database API used by `comtrader::ctdashboard`}
\usage{
ctApp(
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
  uncomtrade_key
)
}
\arguments{
\item{freqCode}{a character string indicating trade frequency: "A" for annual and "M" for monthly}

\item{reporterCode}{a character string indicating reporter code (M49 International Country Classification)}

\item{period}{a character string indicating period. Year ("YYYY") or yearmonth ("YYYYMM"). Use character vector for multiple periods (defaults to all)}

\item{partnerCode}{Partner code (M49 International Country Classification)}

\item{partner2Code}{Second partner/consignment code (M49 International Country Classification)}

\item{cmdCode}{a character string indicating HS commodity code. Use character vector for multiple commodity code entries (defaults to all)}

\item{flowCode}{a character string indicating trade flow code:  "X" for exports, "RX" for re-exports, "M" for imports, "RM" for re-imports. Use character vector for multiple trade flow entries}

\item{customsCode}{a character string indicating customs code. Use character vector for multiple customs code entries (defaults to all)}

\item{motCode}{a character string indicating mode of transport code. Use character vector for multiple transport code entries(defaults to all)}

\item{aggregateBy}{Add parameters in the form of a character vector on which you want the results to be aggregated}

\item{breakdownMode}{a character string indicating breakdown mode: "classic" (trade by partner/product: dafault) or "plus" (extended breakdown)}

\item{includeDesc}{boolean indicating if categories descriptions shoould be returned (defaults to `TRUE`)}

\item{uncomtrade_key}{a character string indicating UN Comtrade API key}
}
\value{
a tibble
}
\description{
Custom get function to query data from the [UN Comtrade API](`https://comtradedeveloper.un.org`) used by `comtrader::ctdashboard` Shiny app
}

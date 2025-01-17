#' omtcodes
#'
#' @title OMT Codes
#' @description Dataset with NZHSC and SOPI codes and descriptions.
#' @details The `SOPI_group_HS6` category contains custom categories.
#' @docType data
#' @keywords datasets
#' @format A data frame with the following columns:
#' \describe{
#'   \item{Primary_Industry_Sector}{SOPI Primary Industry Sector categories.}
#'   \item{NZHSCLevel4}{NZHSC Level 4 codes.}
#'   \item{NZHSCLevel4Desc}{Descriptions for NZHSC Level 4 codes.}
#'   \item{NZHSCLevel6}{NZHSC Level 6 codes.}
#'   \item{NZHSCLevel6Desc}{Descriptions for NZHSC Level 6 codes.}
#'   \item{SOPI_group_HS6}{SOPI group descriptions based on NZHSC Level 6 code groups.}
#' }
#' @source NZHSC V2022.5.0 \url{https://aria.stats.govt.nz/aria/#ClassificationView:uri=http://stats.govt.nz/cms/ClassificationVersion/GT9Qz2lTFnrbgpiI}
"omtcodes"

#' hscodes
#'
#' @title HS Codes
#' @description Dataset with HS and SOPI codes and descriptions for the ctdashboard shiny app.
#' @details The `SOPI_group_HS6` category contains custom categories.
#' @docType data
#' @keywords datasets
#' @format A data frame with the following columns:
#' \describe{
#'   \item{sopiLevel}{SOPI level.}
#'   \item{sopiFilter}{SOPI level category.}
#'   \item{code}{Comma-separated string of NZHSC Level 6 codes by SOPI level and filter.}
#' }
#' @source V2022.5.0 \url{https://aria.stats.govt.nz/aria/#ClassificationView:uri=http://stats.govt.nz/cms/ClassificationVersion/GT9Qz2lTFnrbgpiI}
"hscodes"

#' partnercodes
#'
#' @title Partner Codes
#' @description Named list of partner country codes to use in the ctdashboard shiny app.
#' @details The list includes a "World" code in addition to M49 codes for individual countries.
#' @docType data
#' @keywords datasets
#' @format A named list where:
#' \describe{
#'   \item{List name}{Country description.}
#'   \item{List item}{Country code.}
#' }
#' @source \url{https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json}
"partnercodes"

#' reportercodes
#'
#' @title Reporter Codes
#' @description Named list of reporter country codes to use in the ctdashboard shiny app.
#' @details The list includes M49 codes for individual countries.
#' @docType data
#' @keywords datasets
#' @format A named list where:
#' \describe{
#'   \item{List name}{Country description.}
#'   \item{List item}{Country code.}
#' }
#' @source \url{https://comtradeapi.un.org/files/v1/app/reference/Reporters.json}
"reportercodes"


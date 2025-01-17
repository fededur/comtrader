#' @name omtcodes
#' @title omt codes
#' @description Dataset with NZHSC and SOPI codes and descriptions
#' @details The SOPI_group_HS6 category contains custom categories
#' @docType data
#' @keywords datasets
#' @format
#' \describe{
#'   \item{Primary Industry Sector}{SOPI Primary Industry Sector categories}
#'   \item{NZHSCLevel4}{NZHSC Level 4 codes}
#'   \item{NZHSCLevel4Desc}{NZHSC Level 4 descriptions}
#'   \item{NZHSCLevel6}{NZHSC Level 6 codes}
#'   \item{NZHSCLevel6Desc}{NZHSC Level 6 descriptions}
#'   \item{SOPI_group_HS6}{SOPI group descriptions based on NZHSC Level 6 codes groups}
#' }
#' @source NZHSC V2022.5.0 https://aria.stats.govt.nz/aria/#ClassificationView:uri=http://stats.govt.nz/cms/ClassificationVersion/GT9Qz2lTFnrbgpiI
"omtcodes"

#' @name hscodes
#' @title hs codes
#' @description Dataset with HS and SOPI codes and descriptions for comtrader shiny app
#' @details The SOPI_group_HS6 category contains custom categories
#' @docType data
#' @keywords datasets
#' @format
#' \describe{
#'   \item{sopiLevel}{SOPI level}
#'   \item{sopiFilter}{SOPI level category}
#'   \item{code}{comma separated string of NZHSC Level 6 codes by SOPI level and filter}
#' }
#' @source V2022.5.0 https://aria.stats.govt.nz/aria/#ClassificationView:uri=http://stats.govt.nz/cms/ClassificationVersion/GT9Qz2lTFnrbgpiI
"hscodes"

#' @name partnercodes
#' @title partner codes
#' @description Named list of partner country codes to use in comtrader shiny app.
#' @details The list includes a "World" code in addition to M49 codes for individual countries
#' @docType data
#' @keywords datasets
#' @format a list
#' \describe{
#'   \item{List name}{country description}
#'   \item{List item}{country code}
#' }
#' @source https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json
"partnercodes"

#' @name reportercodes
#' @title reporter codes
#' @description Named list of reporter country codes to use in comtrader shiny app
#' @details The list includes M49 codes for individual countries
#'
#' @docType data
#' @keywords datasets
#' @format a list
#' \describe{
#'   \item{List name}{country description}
#'   \item{List item}{country code}
#' }
#' @source https://comtradeapi.un.org/files/v1/app/reference/Reporters.json
"reportercodes"

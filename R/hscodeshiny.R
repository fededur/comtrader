#' hscodeshiny
#'
#' @description Dataset with NZHSC and SOPI codes and descriptions for comtrader shiny app.
#' @details The SOPI_group_HS6 category contains custom categories.
#' @docType data
#' @name hscodeshiny
#' @format
#' \describe{
#'   \item{sopiLevel}{SOPI level.}
#'   \item{sopiFilter}{SOPI level category.}
#'   \item{code}{comma separated string of NZHSC Level 6 codes by SOPI level and filter.}
#' }
#' @source NZHSC
#' @import dplyr
#' @importFrom tidyr pivot_longer
#' @export
"hscodeshiny" <- {
  hs_code <- read.csv("data/SOPI_Group_HS6_level.csv", check.names = F, stringsAsFactors = F) %>%
    mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
           NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
    rename(SOPI_group_HS6 = "SOPI_group _HS6") %>%
    select(`Primary Industry Sector`,SOPI_group_HS6,NZHSCLevel6) %>%
    pivot_longer(cols = c(`Primary Industry Sector`,SOPI_group_HS6),names_to = "sopiLevel", values_to = "sopiFilter")

  hscodeshiny <- bind_rows(
    hs_code %>%
      group_by(sopiLevel,sopiFilter) %>%
      mutate(code = paste0(NZHSCLevel6, collapse = ",")) %>%
      ungroup() %>%
      select(-NZHSCLevel6) %>%
      distinct(),
    hs_code %>%
      mutate(code = paste0(NZHSCLevel6, collapse = ",")) %>%
      select(-c(NZHSCLevel6,sopiLevel,sopiFilter )) %>%
      distinct() %>%
      mutate(sopiLevel = "Primary Industry Sector",
             sopiFilter = "All SOPI categories")
  )
  hscodeshiny
}

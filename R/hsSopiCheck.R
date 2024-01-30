#' Identify conflicts between HS codes and SOPI categories
#'
#' @description Reads `omtcodes` and creates a wide table of HS codes and counts of matching SOPI Categories (or viceversa).
#' @param ref1 reference code 1 E.g.: NZHSC level code (either `2`, `4` or `6`)
#' @param ref2 reference code 2 E.g.: SOPI category level (either `Primary Industry Sector`,`SOPI Forecast Group` or `Granular Group`)
#'
#' @return a tibble
#'
#' @import dplyr tibble
#' @importFrom magrittr %>%
#' @export
#' @examples
#' hsSopiCheck(ref1 = `4`, ref2 = `SOPI Forecast Group`)
hsSopiCheck <- function(ref1, ref2){

  comtrader::omtcodes %>%
    as_tibble() %>%
    select({{ref1}},{{ref2}}) %>%
    pivot_wider(values_from = 2,
                names_from = 2,
                values_fn = function(x) length(unique(x))) %>%
    replace(is.na(.), 0) %>%
    group_by_at(1) %>%
    mutate(category = paste0(names(.[-1])[as.logical(cur_data())], collapse = ', ')) %>%
    ungroup() %>%
    mutate(category_count = rowSums(across(-c(1, category)), na.rm=TRUE)) %>%
    select(1, category, category_count)
}

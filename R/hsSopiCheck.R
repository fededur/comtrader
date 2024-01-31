#' Identify conflicts between two categories in a table
#'
#' @description Creates a table of counts of matching categories between two columns of a table.
#' @details the table is built with reference to the `ref1` argument.
#' @param .data a table to read data from. Defaults to `omtcodes`.
#' @param ref1 first reference column.
#' @param ref2 second reference column.
#'
#' @return a tibble.
#'
#' @import dplyr tibble
#' @importFrom magrittr %>%
#' @importFrom tidyr pivot_wider
#' @export
#' @examples
#' cCheck(ref1 = NZHSCLevel4, ref2 = `SOPI_group_HS6`)
cCheck <- function(.data = comtrader::omtcodes, ref1, ref2){

  ref1_quo <- enquo(ref1)
  ref2_quo <- enquo(ref2)

  {{.data}} %>%
    as_tibble() %>%
    select({{ref1_quo}},{{ref2_quo}}) %>%
    tidyr::pivot_wider(values_from = {{ref2_quo}},
                       names_from = {{ref2_quo}},
                       values_fn = function(x) length(unique(x))) %>%
    replace(is.na(.), 0) %>%
    group_by({{ref1_quo}}) %>%
    mutate("{{ref2_quo}}" := paste0(names(.[-1])[as.logical(cur_data())], collapse = ", ")) %>%
    ungroup() %>%
    mutate(count = rowSums(across(-c({{ref1_quo}},{{ref2_quo}})), na.rm = TRUE)) %>%
    select({{ref1_quo}},{{ref2_quo}},count) %>%
    arrange(desc(count))
}

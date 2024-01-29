#' Create named vector for HS codes
#'
#' @description Creates a named vector matching HS codes and SOPI Categories
#' @details Data was extracted from the Power BI OMT dataset. This dataset needs to be updated if there are changes in the OMT classification.
#' @param hsLevel NZHSC level code (either 2, 4 or 6)
#' @param sopiLevel SOPI category level (either `Primary Industry Sector`,`SOPI Forecast Group` or `Granular Group`)
#' @param query If `TRUE` returns a vector of commodity codes (`cmdCode`) to use in a query. If `FALSE` returns a vector of `sopiLevel` names associated with the commodity code.
#'
#' @return a named vector
#'
#' @import dplyr tibble
#' @importFrom magrittr %>%
#' @export
#' @examples
#' commodityRecode(hsLevel = 4, sopiLevel= "SOPI Forecast Group")
commodityRecode <-  function(hsLevel = 6,
                             sopiLevel = `SOPI Forecast Group`,
                             sopiFilter = NULL,
                             query = TRUE) {

  hs <- as.character(hsLevel)

  comtrader::omtcodes %>%
    tibble::as_tibble() %>%
    select({{sopiLevel}},{{hs}}) %>%
    {if(!is.null({{sopiFilter}})) filter(.,if_all({{sopiLevel}}, ~ . %in% {{sopiFilter}})) else .} %>%
    distinct() %>%
    {if(isTRUE({{query}})){
      tibble::deframe(.)
    } else if(isFALSE({{query}})) {
      select(.,{{hs}},{{sopiLevel}}) %>%
        tibble::deframe()
      }
    }
}

#' Get live update data from UN Comtrade Database API
#'
#' @description Query progress on data release in the UN Comtrade API
#' @details further details on API features available at: `https://comtradedeveloper.un.org`
#' @return a tibble
#'
#' @export
#' @import httr dplyr
#' @importFrom magrittr %>%
#' @examples
#' getLiveUpdate()
getLiveUpdate <- function(){

  if(is.null(comtrader::get_uncomtrade_key())){

    stop("Use set_uncomtrade_key() to set UN Comtrade API access key")

  }

  res <- httr::GET(
    url = "https://comtradeapi.un.org/data/v1/getLiveUpdate/",
    httr::add_headers("Ocp-Apim-Subscription-Key" = get_uncomtrade_key()))

  dt <- httr::content(res, encoding = "UTF-8") %>%
    purrr::pluck("data") %>%
    bind_rows()

  return(dt)
}

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

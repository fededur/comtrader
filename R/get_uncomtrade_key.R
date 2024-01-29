#' Get package key for UNComprade API
#'
#' @return The value of the key
#' @export
get_uncomtrade_key <- function() {
  getOption("key", default = NULL)
}

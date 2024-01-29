#' Set package key for UNComprade API
#'
#' @param value The value to set as the key
#' @export
set_uncomtrade_key <- function(value) {
  options("key" = value)
}

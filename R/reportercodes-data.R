#' Reporter country codes and descriptions
#'
#' @import dplyr
#' @importFrom jsonlite fromJSON
#' @export
reportercodes <- as.list(
  setNames(
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["reporterCode"]],
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["text"]])
)

save(reportercodes, file = "data/reportercodes.Rds")

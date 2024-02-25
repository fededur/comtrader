#' Partner country codes and descriptions
#'
#' @import dplyr
#' @importFrom jsonlite fromJSON
#' @export
partnercodes <- as.list(
  setNames(
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["PartnerCode"]],
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["text"]])
)

save(partnercodes, file = "data/partnercodes.Rds")

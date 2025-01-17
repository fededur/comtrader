## code to prepare `METADATA` dataset goes here
library(dplyr)
library(tidyr)
library(jsonlite)
library(usethis)

# Read and clean the sopi-nzhsc data
file_path <- system.file("extdata", "SOPI_Group_HS6_level.csv", package = "comtrader")
hscsc <- read.csv(file_path, check.names = FALSE, stringsAsFactors = FALSE, header = TRUE) %>%
  filter(rowSums(!is.na(.)) > 0) %>%
  select(where(~ !all(is.na(.))))

# Create hscodes
hscodes <- dplyr::bind_rows(
  hscsc %>%
    mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
           NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
    select(Primary_Industry_Sector, SOPI_group_HS6, NZHSCLevel6, NZHSCLevel6Desc) %>%
    pivot_longer(cols = c(`Primary_Industry_Sector`, SOPI_group_HS6, NZHSCLevel6Desc), names_to = "sopiLevel", values_to = "sopiFilter") %>%
    group_by(sopiLevel, sopiFilter) %>%
    mutate(code = paste0(NZHSCLevel6, collapse = ",")) %>%
    ungroup() %>%
    select(-NZHSCLevel6) %>%
    distinct(),

  hscsc %>%
    mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
           NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
    select(Primary_Industry_Sector, SOPI_group_HS6, NZHSCLevel6, NZHSCLevel6Desc) %>%
    pivot_longer(cols = c(Primary_Industry_Sector, SOPI_group_HS6, NZHSCLevel6Desc), names_to = "sopiLevel", values_to = "sopiFilter") %>%
    select(-sopiFilter) %>%
    group_by(sopiLevel) %>%
    mutate(sopiFilter = "All categories",
           code = paste0(NZHSCLevel6, collapse = ",")) %>%
    ungroup() %>%
    select(-NZHSCLevel6) %>%
    distinct()
)

# Create omtcodes
omtcodes <- hscsc %>%
  select(-HS6_text) %>%
  mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
         NZHSCLevel6 = sprintf("%06d", NZHSCLevel6))

# Fetch partner codes
# partnercodes <- as.list(
#   stats::setNames(
#     jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["PartnerCode"]],
#     jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["text"]])
# )
partner_data <- tryCatch({
  jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")
  }, error = function(e) {
  stop("Failed to fetch partner codes: ", e$message)
})

partnercodes <- as.list(
  stats::setNames(
    partner_data[[1]][["PartnerCode"]],
    partner_data[[1]][["text"]]
  )
)

# Fetch reporter codes
# reportercodes <- as.list(
#   setNames(
#     jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["reporterCode"]],
#     jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["text"]])
# )
reporter_data <- tryCatch({
  jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")
  }, error = function(e) {
    stop("Failed to fetch reporter codes: ", e$message)
})

reportercodes <- as.list(
  stats::setNames(
    reporter_data[[1]][["reporterCode"]],
    reporter_data[[1]][["text"]]
  )
)

# Save datasets
usethis::use_data(hscodes, omtcodes, partnercodes, reportercodes, overwrite = TRUE)

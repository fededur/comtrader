## code to prepare `METADATA` dataset goes here
library(dplyr)
library(tidyr)

hscodes <- dplyr::bind_rows(
  read.csv("data/SOPI_Group_HS6_level.csv", check.names = F, stringsAsFactors = F) %>%
    mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
           NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
    rename(SOPI_group_HS6 = "SOPI_group _HS6") %>%
    select(`Primary Industry Sector`,SOPI_group_HS6,NZHSCLevel6,NZHSCLevel6Desc) %>%
    pivot_longer(cols = c(`Primary Industry Sector`,SOPI_group_HS6,NZHSCLevel6Desc),names_to = "sopiLevel", values_to = "sopiFilter") %>%
    group_by(sopiLevel,sopiFilter) %>%
    mutate(code = paste0(NZHSCLevel6, collapse = ",")) %>%
    ungroup() %>%
    select(-NZHSCLevel6) %>%
    distinct(),
  read.csv("data/SOPI_Group_HS6_level.csv", check.names = F, stringsAsFactors = F) %>%
    mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
           NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
    rename(SOPI_group_HS6 = "SOPI_group _HS6") %>%
    select(`Primary Industry Sector`,SOPI_group_HS6,NZHSCLevel6,NZHSCLevel6Desc) %>%
    pivot_longer(cols = c(`Primary Industry Sector`,SOPI_group_HS6,NZHSCLevel6Desc),names_to = "sopiLevel", values_to = "sopiFilter") %>%
    select(-sopiFilter) %>%
    group_by(sopiLevel) %>%
    mutate(sopiFilter = "All categories",
           code = paste0(NZHSCLevel6, collapse = ",")) %>%
    ungroup() %>%
    select(-NZHSCLevel6) %>%
    distinct()
)

omtcodes <- read.csv("data/SOPI_Group_HS6_level.csv", check.names = F, stringsAsFactors = F) %>%
  mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
         NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
  rename(SOPI_group_HS6 = "SOPI_group _HS6") %>%
  select(`Primary Industry Sector`,NZHSCLevel4,NZHSCLevel4Desc,NZHSCLevel6,NZHSCLevel6Desc,SOPI_group_HS6)

partnercodes <- as.list(
  stats::setNames(
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["PartnerCode"]],
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/partnerAreas.json")[[1]][["text"]])
)

reportercodes <- as.list(
  setNames(
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["reporterCode"]],
    jsonlite::fromJSON("https://comtradeapi.un.org/files/v1/app/reference/Reporters.json")[[1]][["text"]])
)

usethis::use_data(hscodes,omtcodes,partnercodes,reportercodes, overwrite = TRUE)
# usethis::use_data(omtcodes, overwrite = TRUE)
# usethis::use_data(partnercodes, overwrite = TRUE)
# usethis::use_data(reportercodes, internal = FALSE, overwrite = TRUE)

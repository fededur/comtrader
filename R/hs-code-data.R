#' Prepare data to match Comtrade and SOPI HS codes
#'
#' @import dplyr stringr
#' @export
omtcodes <- read.csv("data/HS_codes_OMT.csv", check.names = F, stringsAsFactors = F) %>%
  mutate(NZHSCLevel2 = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 2 Code` , width = 2, pad = "0"),
         NZHSCLevel4 = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 4 Code` , width = 4, pad = "0"),
         NZHSCLevel6 = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 6 Code` , width = 6, pad = "0")) %>%
  select(NZHSCLevel2,NZHSCLevel4,NZHSCLevel6,`Primary Industry Sector`,`SOPI Forecast Group`,`Granular Group`)

save(omtcodes, file = "data/omtcodes.Rds")

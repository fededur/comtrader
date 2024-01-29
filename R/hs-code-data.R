#' Prepare data to match Comtrade and SOPI HS codes
#'
#' @import dplyr stringr
#' @keywords internal
omtcodes <- read.csv("data/HS_codes_OMT.csv", check.names = F, stringsAsFactors = F) %>%
  mutate(`2` = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 2 Code` , width = 2, pad = "0"),
         `4` = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 4 Code` , width = 4, pad = "0"),
         `6` = stringr::str_pad(`NZHSC Code Hierarchy - NZHSC Level 6 Code` , width = 6, pad = "0")) %>%
  select(`2`,`4`,`6`,`Primary Industry Sector`,`SOPI Forecast Group`,`Granular Group`)

save(omtcodes, file = "data/omtcodes.RData")

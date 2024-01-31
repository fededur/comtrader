#' Prepare data to match Comtrade and SOPI HS codes
#'
#' @import dplyr stringr
#' @export
omtcodes <- read.csv("data/SOPI Group HS6 level.csv", check.names = F, stringsAsFactors = F) %>%
  mutate(NZHSCLevel4 = sprintf("%04d", NZHSCLevel4),
         NZHSCLevel6 = sprintf("%06d", NZHSCLevel6)) %>%
  rename(SOPI_group_HS6 = "SOPI_group _HS6") %>%
  select(`Primary Industry Sector`,NZHSCLevel4,NZHSCLevel4Desc,NZHSCLevel6,NZHSCLevel6Desc,SOPI_group_HS6)

save(omtcodes, file = "data/omtcodes.Rds")

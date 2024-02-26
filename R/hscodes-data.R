#' NZHSC codes and SOPI descriptions for comtrader shiny app
#'
#' @import dplyr
#' @importFrom tidyr pivot_longer
#' @export
hscodes <- bind_rows(
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

save(hscodes, file = "data/hscodes.Rds")

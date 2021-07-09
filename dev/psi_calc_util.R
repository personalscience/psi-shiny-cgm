# psi_calc_util.r
#


#' @title Calculate Area Under the Curve of glucose values for a restricted timeframe
#' @description Returns AUC for the first timelength minutes after the start of the glucose_df
#' @param glucose_df dataframe of glucose values
#' @param timelength number of minutes to look ahead for the AUC calculation
#' @import DescTool
#' @export
auc_calc <- function(glucose_df, timelength = 120) {
  x <- glucose_df %>%
    select("time",value) %>%
    dplyr::filter(.[["time"]] < first(.[["time"]]) + lubridate::minutes(timelength) ) %>%
    mutate(sec = as.numeric(.[["time"]])-as.numeric(first(.[["time"]]))) %>%
    summarise(auc = DescTools::AUC(as.numeric(sec),value)/60/60)
  x$auc

}

glucose_df_from_libreview_csv() %>% select("time", value)# %>%
  filter(time < first(time) + lubridate::minutes(120)) #%>%
  mutate(sec = as.numeric(.[["time"]])-as.numeric(first(.[["time"]])))# %>%
  summarise(auc = sum(sec))

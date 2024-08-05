# Code for segmentation and clustering of either a barn owl individual or
# ANIMOVER_1 synthetic data


library(dplyr)
library(tseries)


df_DARs <- data.frame(readRDS(".../merged-DARs_ANIMOV.Rds"))  # for ANIMOV data; line 9 must be uncommented and line 10 commented for ANIMOV data
#df_DARs <- data.frame(readRDS(".../merged-DARs_barn-owl.Rds"))  # for barn owl data; line 9 must be commented and line 10 uncommented for barn owl data


df_DARs <- df_DARs[df_DARs_indiv$speed < 70,]  # to remove obviously bogus points (unrealistically high barn owl speeds)

df_DARs$speed <- (df_DARs$speed)/max(df_DARs_indiv$speed)
df_DARs$turning_angle <- (df_DARs$turning_angle)/pi
# Scaling to bring the variables to range on [0,1].


# Method to create segments and construct a representation.

create_chunks <- function(df)
{
  df_chunks_DARs <- df |>
    group_by(seg=cut(T, breaks="60 sec")) |>  # for barn owl; line 25 must be uncommented and line 26 commented for barn owl data 
    #group_by(seg=cut(T, breaks=seq(0, max(T), by=30))) |>  # for ANIMOV; line 25 must be commented and line 26 uncommented for ANIMOV data 
    summarise(
      speed_mean = mean(speed, na.rm = TRUE),
      speed_std = sd(speed, na.rm = TRUE),
      turning_angle_mean = mean(turning_angle, na.rm = TRUE),
      turning_angle_std = sd(turning_angle, na.rm = TRUE),
      disp_ends = sqrt((x[n()] - x[1])^2 + (y[n()] - y[1])^2),
      disp_consec = sum(sqrt(diff(x)^2 + diff(y)^2)),
      n_pts = n(),
      fraction_WP = sum(grepl("^WP", Kernel))/n(),  # Only for ANIMOV data; comment line 35 and comma at the end of line 34 for barn owl data
    ) |>
    filter(n_pts >= 12) |>  # Only for the case of barn owls
    summarise(
      seg,
      speed_mean, speed_std, turning_angle_mean, turning_angle_std,
      net_displacement = disp_ends/disp_consec,
      fraction_WP  # Only for ANIMOV data; comment line 42 and comma at the end of line 41 for barn owl data
    )
  
  df_chunks_DARs <- na.omit(df_chunks_DARs)
  
  return(df_chunks_DARs)
}

df_chunks_DARs = create_chunks(df_DARs)


saveRDS(df_chunks_DARs, file="segmented-DARs.Rds")

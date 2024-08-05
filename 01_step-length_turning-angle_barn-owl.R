# Code for preprocessing a single barn owl individual data.


list_DARs_indiv <- readRDS(".../mid_to_mid1.Rds")  # see https://github.com/LudovicaLV/DAR_project/blob/main/DAR1_measures.R for the code to extract DARs from multi-DAR time-series data of an individual.

df_DARs_indiv <- do.call(rbind, list_DARs_indiv)  # working w/ all DARs of an individual


# Calculate the variables for speed and turning angle, and append to the data frame.

df_DARs_indiv <- df_DARs_indiv[, c('X','Y','dateTime')]
colnames(df_DARs_indiv)[1] <- "x"
colnames(df_DARs_indiv)[2] <- "y"
colnames(df_DARs_indiv)[3] <- "t"

df_DARs_indiv <- transform(df_DARs_indiv, T=as.numeric(T))
speed <- vector("double", nrow(df_DARs_indiv))
for (i in 2:nrow(df_DARs_indiv))
{
  speed[i] <- sqrt(sum((df_DARs_indiv[i,] - df_DARs_indiv[i-1,])^2)
                - (df_DARs_indiv[i,3] - df_DARs_indiv[i-1,3])^2)/(df_DARs_indiv[i,3] - df_DARs_indiv[i-1,3])
}
df_DARs_indiv$speed <- speed
df_DARs_indiv <- transform(df_DARs_indiv, T=as.POSIXct(T, origin="1970-01-01", tz="GMT"))

turning_angle <- vector("double", nrow(df_DARs_indiv))
for (i in 3:nrow(df_DARs_indiv))
{
  turning_angle[i] <- abs(atan((df_DARs_indiv[i,2]-df_DARs_indiv[i-1,2])/(df_DARs_indiv[i,1]-df_DARs_indiv[i-1,1]))
               - atan((df_DARs_indiv[i-1,2]-df_DARs_indiv[i-2,2])/(df_DARs_indiv[i-1,1]-df_DARs_indiv[i-2,1])))
}
df_DARs_indiv$turning_angle <- turning_angle


df_DARs_indiv <- df_DARs_indiv[-1, ]  # 1st point discarded for lack of turning angle value


saveRDS(df_DARs_indiv, file="merged-DARs_barn-owl.Rds")


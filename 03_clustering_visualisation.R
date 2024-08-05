library(parallelDist)
library(fastcluster)
library(factoextra)


df_chunks_DARs <- data.frame(readRDS(".../merged-DARs_ANIMOV.Rds"))


# Hierarchical agglomerative clustering w/ Ward's criterion.

d <- parDist(as.matrix(df_chunks_DARs[c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")]),
             method = "euclidean")
hierarc_res <- fastcluster::hclust(d, method="ward.D2")

hc_ward_8 <- cutree(hierarc_res, k=8)

centroids <- NULL
for(k in 1:8){
  centroids <-
    rbind(
      centroids,
      colMeans(df_chunks_DARs[c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")][hc_ward_8==k, , drop = FALSE])
    )
}
print(noquote(paste0("Centroids of clusters: ",centroids)))

occupancy <-
  as.numeric(
    table(hc_ward_8)
  )
print(noquote(paste0("Occupancy of clusters: ",occupancy)))

df_chunks_DARs_synth <- cbind(df_chunks_DARs_synth, clustNum=hc_ward_8)
df_chunks_DARs_synth |>
  group_by(clustNum) |>
  summarise(
    Cluster_avg_fraction_WP_points_in_a_segment=mean(fraction_WP),
    Cluster_std_fraction_WP_points_in_a_segment=sd(fraction_WP),
    Cluster_std_net_displacement_of_a_segment=sd(net_displacement)
    )  # lines 34 to 40 to be commented out for working with barn owl data


# Compute principal components.

pca_res <-
  prcomp(
    df_chunks_DARs[, c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")],
    scale=FALSE,
    center = FALSE
  )

# Eigenvalues
get_eigenvalue(pca_res)

fviz_pca_var(pca_res,
             col.var = "contrib",  # color by contributions to the PC
             repel = TRUE,  # avoid text overlapping
             scale = FALSE,
             center = FALSE
)

pca_res$x

# eigenvectors
pca_res$rotation


# Plot StaMEs in mean speed - mean turning angle space or PC1-PC2 space w/ different colours representing clusters.

cluster_data_PC <-
  data.frame(
    Cluster = as.factor(hc_ward_8),
    PC1 = pca_res$x[, 1],
    PC2 = pca_res$x[, 2]
  )
var_expl <- round(pca_res$sdev^2 / sum(pca_res$sdev^2) * 100, 2)
# Create a cluster plot
ggplot(cluster_data_PC, aes(x = PC1, y = PC2, colour = Cluster)) +
  geom_point(size = 3) +
  scale_colour_manual(values = c("green1", "blue4", "lightblue1", "violet", "yellow1", "red1", "orange1", "red4")) +
  labs(title = "Cluster Plot on Principal Components",
       x = paste("PC1 (", var_expl[1], "%)", sep = ""),
       y = paste("PC2 (", var_expl[2], "%)", sep = "")) +
  theme_minimal()

cluster_data_SpTa <- data.frame(
  Cluster = as.factor(hc_ward_8),
  mean_speed = df_chunks_DARs_$speed_mean,
  mean_turning_angle = df_chunks_DARs$turning_angle_mean
)
# Create a cluster plot
ggplot(
    cluster_data_SpTa,
    aes(x = mean_speed, y = mean_turning_angle, colour = Cluster)
) +
geom_point(size = 3) +
  #scale_color_manual(values = "red4")
  scale_color_manual(values = c("green1", "blue4", "lightblue1", "violet", "yellow1", "red1", "orange1", "red4")) +
  labs(title = "Cluster Plot on mean speed and mean turning angle") +
  theme_minimal()

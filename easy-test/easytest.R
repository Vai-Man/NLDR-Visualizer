library(liminal)
library(ggplot2)
library(Rtsne)
library(dplyr)
library(palmerpenguins)


penguins <- na.omit(palmerpenguins::penguins)

set.seed(42)
tsne_result <- Rtsne(penguins[, 3:6])

tsne_df <- data.frame(
  tsneX = tsne_result$Y[,1],
  tsneY = tsne_result$Y[,2],
  species = penguins$species
)

tour_data <- penguins[, c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g", "species")]

limn_tour_link(
  embed_data = tsne_df,
  tour_data = tour_data,
  cols = c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"),
  color = "species"
)



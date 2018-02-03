library(brms)
library(tidyverse)

source("01-import.R")
source("02-munge.R")

if (!exists("fit")) {
  fit = readRDS("fit.rds")
}

df = data_frame(subject = "new_subject", elapsed = seq(0, 5, length.out = 250))

linpred = posterior_linpred(fit, df, allow_new_levels = TRUE, transform = TRUE)

probs = apply(linpred, 3, colMeans)[ , grep("Walking", dimnames(linpred)[[3]])]
probs = as_data_frame(probs)
colnames(probs) = 4:0

make_plot = function(x, y) {
  df = cbind(x, y) %>% 
    gather(key, value, -x) %>% 
    mutate(key = factor(key, levels = 0:4))
  ggplot(df, aes(x = x, y = value, fill = key)) +
    geom_area() +
    scale_fill_brewer(palette = "OrRd", direction = -1, drop = FALSE, guide = FALSE) +
    coord_cartesian(expand = FALSE) +
    cowplot::theme_cowplot(20) +
    xlab("Months since onset") +
    ylab("Probability")
}
make_plot(df$elapsed * 12, data_frame(`1` = rowSums(probs[4:5]), `4` = rowSums(probs[1:3])))
ggsave("binary.png", height = 5, width = 8)
make_plot(df$elapsed * 12, probs)
ggsave("ordered.png", height = 5, width = 8)


# Uncertainty -------------------------------------------------------------

focal_subject = 649

plot_uncertainty = function(df) {
  linpred = posterior_linpred(
    fit, 
    df, 
    allow_new_levels = TRUE, 
    transform = TRUE
  )
  
  walking_linpred = linpred[ , , grep("Walking", dimnames(linpred)[[3]])]
  
  apply(walking_linpred[,,1:3], 2, rowSums) %>% 
    t() %>% 
    matplot(df$elapsed * 12, 
            ., 
            type = "l", 
            col = alpha(1, .1), 
            lty = 1,
            xlab = "Months since onset",
            xaxs = "i",
            yaxs = "i",
            bty = "l",
            ylab = "P(walking)",
            ylim = c(0, 1),
            main = paste("Predictions for Subject", focal_subject)
    )
}

df2 = df
df2$subject = focal_subject

train_years = training_data %>% 
  filter(subject == df2$subject[1]) %>% 
  pull(elapsed)


make_png = function(x, i, res = 300){
  png(
    filename = paste0(i, ".png"), 
    res = res, 
    height = 4 * res, 
    width = 4 * res
  )
  x
  dev.off()
}

set.seed(1)
make_png(plot_uncertainty(df), 1)
set.seed(1)
make_png(
  {
    plot_uncertainty(df)
    abline(v = train_years * 12, lwd = 2)
  }, 
  2
)
make_png(
  {
    plot_uncertainty(df2)
    abline(v = train_years * 12, lwd = 2)
  }, 
  3
)
make_png(
  {
    plot_uncertainty(df2)
    abline(v = train_years * 12, lwd = 2)
    validation_data %>% 
      filter(subject == df2$subject[[1]]) %>% 
      pull(elapsed) %>% 
      max() %>% 
      `*`(12) %>% 
      abline(v = ., col = 2, lwd = 3)
  },
  4
)


# Labels ------------------------------------------------------------------

labels = c("Normal walking", "Some difficulty", "Walks with assistance", 
  "No walking", "No leg control")

f = ordered(labels, levels = labels)
ggplot(NULL) +
  geom_bar(aes(x = f, fill = f), width = 1) +
  scale_fill_brewer(palette = "OrRd", guide = FALSE)


# Correlations ------------------------------------------------------------

r_climb = colMeans(posterior_samples(fit, c("r_subject__Climbing")))
r_climb = r_climb[grep("elapsed\\]", names(r_climb))]
r_walk = colMeans(posterior_samples(fit, c("r_subject__Walking")))
r_walk = r_walk[grep("elapsed\\]", names(r_walk))]


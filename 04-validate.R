library(tidyverse)
source("01-import.R")
source("02-munge.R")
library(brms)

if (!exists("fit")) {
  fit = readRDS("fit.rds")
}
symptom_names = names(fit$family)
validation_data = readRDS("validation_data.rds")

linpred_validation = posterior_linpred(
  fit, 
  transform = TRUE, 
  newdata = validation_data
) %>% 
  apply(3, colMeans)


validation_predictions = as_data_frame(linpred_validation) %>% 
  mutate(subject = validation_data$subject, month = validation_data$month) %>% 
  gather("key", "value", -subject, -month) %>% 
  mutate(
    symptom = gsub("[[:digit:]]*", "", key),
    severity = as.numeric(gsub("[[:alpha:]]*", "", key))
  ) %>% 
  group_by(subject, symptom, month) %>% 
  summarize(predicted_severity = sum(value * severity))

full_validation_predictions = validation_data %>% 
  mutate(future_elapsed = elapsed - month_3_elapsed) %>% 
  select(one_of("subject", symptom_names, "month", "future_elapsed")) %>% 
  gather(symptom, observed_severity, -subject, -month, -future_elapsed) %>% 
  inner_join(validation_predictions, by = c("subject", "month", "symptom"))

full_validation_predictions %>% 
  ggplot(aes(y = predicted_severity, x = factor(observed_severity))) + 
  geom_violin()


full_validation_predictions %>% 
  group_by(subject, future_elapsed) %>% 
  summarize(
    observed_score = 45 - sum(observed_severity),
    predicted_score = 45 - sum(predicted_severity)
  ) %>% 
  ggplot(aes(x = future_elapsed, group = subject)) + 
  geom_line(aes(y = observed_score), size = 0.5, color = alpha("black", .25)) +
  cowplot::theme_cowplot() +
  xlab("Years since last observation") +
  ylab("Total functional score")


full_validation_predictions %>% 
  group_by(subject, future_elapsed, symptom) %>% 
  summarize(absolute_error = abs(mean(observed_severity - predicted_severity))) %>% 
  ggplot(aes(x = future_elapsed, y = absolute_error)) +
  geom_point() + 
  geom_smooth() +
  xlab("Years since last observation") +
  cowplot::theme_cowplot()


full_validation_predictions %>% 
  group_by(symptom) %>% 
  summarize(RMSE = signif(Metrics::rmse(observed_severity, predicted_severity), 1))


some_correlations = colMeans(posterior_samples(fit, "cor")) %>% 
  enframe %>% 
  separate(name, letters[1:6]) %>% 
  filter(d == "elapsed", f == "elapsed") %>% 
  select(c, e, value) %>% 
  mutate(c = factor(c, levels = symptom_names), 
         e = factor(e, levels = symptom_names))

diagonal = data_frame(c = symptom_names, e = symptom_names, value = 1)
all_correlations = some_correlations %>% 
  rename(c = e, e = c) %>% 
  rbind(some_correlations, diagonal) %>% 
  rename(correlation = value)

ggplot(all_correlations, aes(x = c, y = e, fill = correlation)) + 
  geom_raster() +
  viridis::scale_fill_viridis(option = "B", limits = c(0, 1)) +
  cowplot::theme_cowplot(16) +
  coord_equal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

all_correlations %>%
  spread(e, correlation) %>% 
  .[-1] %>% 
  svd() %>% 
  .$d %>% 
  cumsum() %>% 
  `/`(10) %>% 
  plot(ylim = c(0, 1), type = "h", yaxs = "i", bty = "l")

training_data %>%
  ungroup() %>% 
  filter(subject %in% c(255656, 501995)) %>% 
  select(1:10, month, subject) %>% 
  gather(key, value, -month, -subject) %>% 
  mutate(`Function\nscore` = forcats::fct_rev(factor(5 - value, levels = 0:4)),
         subject = factor(subject, labels = c("Subject 1", "Subject 2"))) %>% 
  ggplot(aes(x = month, y = key, fill = `Function\nscore`)) +
  geom_raster() +
  scale_fill_brewer(type = "seq", palette = "OrRd", direction = 1, drop = FALSE) +
  facet_grid(~subject) +
  scale_x_continuous(breaks = seq(0, 12, 3)) +
  coord_cartesian(expand = FALSE) +
  ylab("") +
  xlab("Time")

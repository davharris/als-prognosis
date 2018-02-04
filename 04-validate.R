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

probs = posterior_linpred(
  fit, 
  transform = TRUE, 
  newdata = validation_data
) %>% 
  apply(3, colMeans)


map(
  1:10, 
  function(i){
    y_hat = probs[,5 * (i - 1) + (1:5)]
    validation_y = validation_data[[symptom_names[i]]]
    
    likelihoods = y_hat[cbind(1:nrow(y_hat), validation_y)]
    data_frame(
      i = i,
      x = 12 * (validation_data$elapsed - validation_data$month_3_elapsed),
      y = as.numeric(likelihoods == apply(y_hat, 1, max)))
  }
) %>%
  bind_rows() %>% 
  ggplot(aes(x = x, y = y, group = factor(i))) +
  geom_smooth(
    method = "gam", 
    method.args = list(family = "binomial"), 
    se = FALSE,
    color = alpha(1, .5)
  ) +
  ylab("Accuracy") +
  cowplot::theme_cowplot(font_size = 20) +
  coord_cartesian(xlim = c(0, 19), ylim = c(0, 1), expand = FALSE) + 
  scale_x_continuous(breaks = 3 * (0:10)) + 
  scale_y_continuous(breaks = seq(0, 1, .2)) +
  xlab("Months from last training survey")
ggsave("accuracy.png")

full_validation_predictions %>% 
  group_by(subject, future_elapsed, symptom) %>% 
  summarize(absolute_error = mean(abs(observed_severity - predicted_severity))) %>% 
  ggplot(aes(x = 12 * future_elapsed,y = absolute_error,group = symptom)) + 
  geom_smooth(method = "gam", se = FALSE, color = alpha(1, .5)) + 
  coord_cartesian(xlim = c(0, 19), ylim = c(0, 1.9), expand = FALSE) + 
  scale_color_manual(
    values = c(colorblindr::palette_OkabeIto_black, "red", "gray"),
    guide = FALSE
  ) + 
  scale_x_continuous(breaks = 3 * (0:10)) + 
  xlab("Months from last training survey") + 
  ylab("Mean absolute error") +
  cowplot::theme_cowplot(font_size = 20)
ggsave("MAE.png")




full_validation_predictions %>% 
  group_by(subject, future_elapsed) %>% 
  summarize(observed = sum(observed_severity), predicted = sum(predicted_severity)) %>% 
  group_by(subject) %>% 
  arrange(subject, future_elapsed) %>% 
  summarize(predicted_slope = (predicted[9] - predicted[1]) / (future_elapsed[9] - future_elapsed[1]),
            observed_slope = (observed[9] - observed[1]) / (future_elapsed[9] - future_elapsed[1])) %>% 
  summarize(r2 = 1 - var(predicted_slope - observed_slope) / var(observed_slope),
            sd(predicted_slope/12 - observed_slope/12), 
            cor(predicted_slope, observed_slope)^2)

full_validation_predictions %>% 
  group_by(symptom) %>% 
  summarize(RMSE = signif(Metrics::rmse(observed_severity, predicted_severity), 1))

expand_names = function(x){
  case_when(
    x == "Cutting" ~ "Cutting/eating food",
    x == "Dressing" ~ "Dressing and hygiene",
    x == "Turning" ~ "Turning in bed",
    x == "Climbing" ~ "Climbing stairs",
    TRUE ~ x
  )
}

some_correlations = colMeans(posterior_samples(fit, "cor")) %>% 
  enframe %>% 
  separate(name, letters[1:6]) %>% 
  filter(d == "elapsed", f == "elapsed") %>% 
  select(c, e, value) %>% 
  mutate(c = expand_names(c), e = expand_names(e)) %>% 
  mutate(c = factor(c, levels = expand_names(symptom_names)), 
         e = factor(e, levels = expand_names(symptom_names)))

diagonal = data_frame(c = expand_names(symptom_names), 
                      e = expand_names(symptom_names), 
                      value = 1)
all_correlations = some_correlations %>% 
  rename(c = e, e = c) %>% 
  rbind(some_correlations, diagonal) %>% 
  rename(correlation = value)

ggplot(all_correlations, aes(x = c, y = e, fill = correlation)) + 
  geom_raster() +
  viridis::scale_fill_viridis(option = "B", limits = c(0, 1)) +
  cowplot::theme_cowplot(16) +
  coord_equal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

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
  filter(subject %in% c(230653, 395329)) %>%
  select(1:10, month, subject) %>% 
  gather(key, value, -month, -subject) %>% 
  mutate(`Function\nscore` = forcats::fct_rev(factor(5 - value, levels = 0:4)),
         subject = factor(subject, labels = c("Subject 1", "Subject 2"))) %>% 
  filter(key %in% c("Speech", "Swallowing", "Walking", "Respiratory", "Handwriting")) %>% 
  mutate(key = ifelse(key == "Respiratory", "Breathing", key)) %>% 
  mutate(key = forcats::fct_rev(factor(key))) %>% 
  ggplot(aes(x = month, y = key, fill = `Function\nscore`)) +
  geom_raster() +
  scale_fill_brewer(type = "seq", palette = "OrRd", direction = 1, drop = FALSE) +
  facet_grid(~subject) +
  scale_x_continuous(breaks = seq(0, 12, 3)) +
  coord_cartesian(expand = FALSE) +
  ylab("") +
  xlab("Time (Months)") +
  cowplot::theme_cowplot(16)

the_subject = full_validation_predictions %>% 
  group_by(subject) %>% 
  summarize(absolute_error = mean(abs((observed_severity - predicted_severity)))) %>% 
  arrange(absolute_error) %>% 
  pull(1) %>% 
  .[103]

training_data %>%
  ungroup() %>% 
  select(1:10, month, subject) %>% 
  gather(symptom, observed_severity, -month, -subject) %>% 
  full_join(full_validation_predictions, c("month", "subject", "symptom", "observed_severity")) %>% 
  filter(subject == the_subject) %>% 
  mutate(observed_severity = ifelse(is.na(predicted_severity), observed_severity, predicted_severity)) %>% 
  mutate(Function = 5 - observed_severity) %>% 
  ggplot(aes(x = month, y = symptom, fill = Function)) +
  geom_raster() +
  scale_fill_distiller(palette = "OrRd", direction = -1, limits = c(0, 4)) +
  geom_vline(xintercept = 3.5) +
  coord_cartesian(expand = FALSE)
ggsave("test.png", dpi = 300, width = 6, height = 4)



plot_subject = 13165

linpred_validation %>% 
  as.data.frame() %>% 
  filter(validation_data$subject == plot_subject) %>% 
  select(one_of(paste0("Handwriting", 1:2))) %>% 
  rowSums() %>% 
  plot(
    validation_data$elapsed[validation_data$subject == plot_subject], 
    ., 
    ylim = c(0, 1), 
    type = "l"
  )

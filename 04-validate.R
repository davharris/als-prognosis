if (!exists("fit")) {
  fit = readRDS("fit.rds")
}

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
  group_by(subject, future_elapsed) %>% 
  summarize(absolute_error = abs(mean(observed_severity - predicted_severity))) %>% 
  ggplot(aes(x = future_elapsed, y = absolute_error)) +
  geom_smooth() +
  xlab("Years since last observation") +
  cowplot::theme_cowplot()


full_validation_predictions %>% 
  group_by(symptom) %>% 
  summarize(RMSE = signif(Metrics::rmse(observed_severity, predicted_severity), 1))
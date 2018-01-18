set.seed(1)
source("01-import.R")
library(brms, quietly = TRUE)
theme_set(theme_default())

patient_ids = readLines("PRO-ACT/Archive/ALS_Prize_slopes/slopes.train") %>% 
  gsub("^.*:(.*)\t.*", "\\1", .)

history = history %>% 
  distinct(subject_id, Onset_Delta)

frs = frs %>% 
  select(1:13) %>%
  select(-starts_with("Q5")) %>% 
  filter(subject_id %in% patient_ids) %>% 
  inner_join(distinct(history), by = "subject_id") %>% 
  na.omit() %>% 
  mutate(elapsed = (ALSFRS_Delta - Onset_Delta) / 365.24)


colnames(frs) = gsub("Q..?_", "", colnames(frs))
colnames(frs) = gsub("_.*$", "", colnames(frs))

responses = c("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
              "Turning", "Walking", "Climbing", "Respiratory")


severity = ceiling(5 - frs[ , colnames(frs) %in% responses])


data = cbind(severity, select(frs, subject, elapsed)) %>% 
  group_by(subject) %>% 
  mutate(n_months = n()) %>% 
  filter(n_months == 12) %>% 
  arrange(subject, elapsed) %>% 
  mutate(month = 1:n(), month_3_elapsed = elapsed[3])

subjects = unique(data$subject)
training_subjects = sample(subjects, floor(length(subjects) / 2))

training_data = data %>% 
  filter(subject %in% training_subjects | month <= 3)

validation_data = data %>% 
  anti_join(training_data, by = c("subject", "month"))

fit = brm(
  bf(
    cbind("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
          "Turning", "Walking", "Climbing", "Respiratory") ~ 
      elapsed + 
      (elapsed | s | subject)
  ) + 
    set_rescor(FALSE), 
  family = cumulative(),
  data = training_data,
  chains = 2,
  cores = 2,
  refresh = 50,
  save_model = "brm.stan"
)

saveRDS(fit, file = "fit.rds")

#fit = readRDS("fit.rds")

fit

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

validation_predictions = validation_data %>% 
  select(one_of("subject", symptom_names, "month")) %>% 
  gather(symptom, observed_severity, -subject, -month) %>% 
  inner_join(validation_predictions, by = c("subject", "month", "symptom"))


validation_predictions %>% 
  group_by(month) %>% 
  summarize(rmse = sqrt(mean((observed_severity - predicted_severity)^2))) %>% 
  mutate(horizon_month = month - 3) %>% 
  plot(rmse ~ horizon_month, type = "l", data = .)

symptom_names = names(fit$formula$forms)


validation_predictions %>% 
  group_by(subject, month) %>% 
  summarize(
    observed_severity = sum(observed_severity),
    predicted_severity = sum(predicted_severity)
  ) %>% 
  ggplot(aes(x = 45-predicted_severity, y = 45-observed_severity, color = month)) + 
  geom_point() +
  coord_equal() +
  viridis::scale_color_viridis() +
  cowplot::theme_cowplot()



stop()
gap = 1/20 # units: years

id = sample(validation_data$subject, 1)
#id = "b"

start_time = if (is.numeric(id)) {
  validation_data %>% 
    filter(subject == id) %>% 
    pull(elapsed) %>% 
    min()
} else {
  start_time = 0
}

times = seq(start_time, start_time + 2, gap)

linpred_baseline = posterior_linpred(
  fit, transform = TRUE, 
  newdata = data.frame(elapsed = times, subject = id),
  allow_new_levels = TRUE
)

symptom_names = names(fit$formula$forms)
symptom = 7


linpred_symptom = linpred_baseline[,,grep(symptom_names[symptom], dimnames(linpred_baseline)[[3]])]
linpred_symptom = linpred_symptom[times >= start_time, , ]

color_order = c(5, 7, 3, 6, 8)

expected_score = sapply(
  1:5,
  function(i){
    colMeans(linpred_symptom[,,i] * i)
  }
) %>% 
  rowSums()

reshape2::melt(apply(linpred_symptom, 3, colMeans)) %>% 
  ggplot(aes(x = (Var1 - 1) * gap, y = value, color = Var2, fill = Var2)) +
  geom_area(position = "identity", alpha = 0.1) + 
  geom_line(size = 1, alpha = 0.5)  + 
  colorblindr::scale_color_OkabeIto(order = color_order, use_black = TRUE) + 
  colorblindr::scale_fill_OkabeIto(order = color_order, use_black = TRUE) + 
  cowplot::theme_cowplot() +
  xlab("Years") +
  ylab("Probability") +
  #xlim(c(0, max(validation_data$elapsed) - min(validation_data$elapsed))) + 
  ylim(c(0, 1.01)) + 
  coord_cartesian(expand = FALSE)




validation_predictions = posterior_predict(fit, newdata = validation_data)
validation_means = apply(validation_predictions, 3, colMeans)

hist(abs(validation_means[,2] - validation_data$Respiratory), breaks = "fd")

ggplot(
  data = NULL, 
  aes(
    x = validation_data$elapsed - validation_data$month_3_elapsed, 
    y = abs(validation_means[,2] - validation_data$Respiratory)
  )
) +
  geom_smooth() +
  cowplot::theme_cowplot()


ranefs = ranef(fit, summary = FALSE)[[1]]
fixefs = fixef(fit, summary = FALSE)
fixefs = fixefs[ , grep("elapsed", colnames(fixefs))]

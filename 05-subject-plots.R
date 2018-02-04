source("01-import.R")
source("02-munge.R")
library(brms)

if (!exists("fit")) {
  fit = readRDS("fit.rds")
}
subject_ids = read_csv("subject_ids.csv", col_types = cols(x = col_integer())) %>% pull(x)

# Slopes ------------------------------------------------------------------

ranefs = ranef(fit)[[1]]
ranefs = ranefs[ , , grep("elapsed", dimnames(ranefs)[[3]])]
dimnames(ranefs)[[3]] = gsub("_elapsed", "", dimnames(ranefs)[[3]])
ranefs = ranefs[as.character(subject_ids), , ]
saveRDS(ranefs, "ranefs.rds")



# Symptom probabilities ---------------------------------------------------

times = seq(0, 2, 1/12)

subject_time = crossing(
  subject = subject_ids, 
  t = times
)


full_graph_probs = validation_data %>% 
  distinct(subject, month_3_elapsed) %>% 
  inner_join(subject_time, "subject") %>% 
  mutate(elapsed = month_3_elapsed + t) %>% 
  posterior_linpred(fit, transform = TRUE, newdata = .) 

graph_probs = apply(full_graph_probs, 3, colMeans)

graph_input = graph_probs %>% 
  as_data_frame() %>% 
  cbind(subject_time) %>% 
  gather("key", "value", - subject, -t) %>% 
  mutate(
    symptom = gsub("[[:digit:]]*", "", key),
    severity = as.numeric(gsub("[[:alpha:]]*", "", key))
  )

saveRDS(graph_input, file = "graph_input.rds")



# Figure-for-slides -------------------------------------------------------


example_subject = training_subjects[10]

example_data = training_data %>% 
  filter(subject == example_subject) %>% 
  select(subject, elapsed) %>% 
  posterior_linpred(fit, newdata = ., transform = TRUE, nsamples = 2)

task = "Cutting"
cbind(
  x = filter(training_data, subject == example_subject) %>% pull(elapsed), 
  observed = filter(training_data, subject == example_subject)[[task]],
  example_data[1,,paste0(task, 1:5)]
) %>% 
  as_data_frame() %>%
  gather(key, value, -1, -2) %>% 
  mutate(key = forcats::fct_rev(factor(key, labels = 4:0))) %>% 
  ggplot() +
  geom_area(aes(x = x, y = value, fill = key)) +
  geom_vline(aes(xintercept = x, color = factor(5 - observed, levels = 0:4)), size = 3) +
  scale_fill_brewer(palette = "OrRd", direction = -1) +
  scale_color_brewer(palette = "OrRd", direction = -1, drop = FALSE) +
  cowplot::theme_cowplot()

# Demographics etc --------------------------------------------------------

demographics %>% 
  filter(subject_id %in% subject_ids) %>% 
  select(subject_id, Age, Sex) %>% 
  inner_join(history, "subject_id") %>% 
  na.omit() %>% 
  rename(subject = subject_id) %>% 
  inner_join(distinct(validation_data, subject, month_3_elapsed), by = "subject") %>% 
  mutate(elapsed = (month_3_elapsed - Onset_Delta/365.24)* 12) %>% 
  select(subject, Age, Sex, elapsed, Site_of_Onset) %>% 
  write_csv("app_demographics.csv")

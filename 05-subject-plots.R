source("01-import.R")
source("02-munge.R")
library(brms)

if (!exists("fit")) {
  fit = readRDS("fit.rds")
}

times = seq(0, 2, length.out = 25)

subject_time = crossing(
  subject = unique(validation_data$subject), 
  t = times
)

graph_probs = validation_data %>% 
  distinct(subject, month_3_elapsed) %>% 
  inner_join(subject_time) %>% 
  mutate(elapsed = month_3_elapsed + t) %>% 
  posterior_linpred(fit, transform = TRUE, newdata = .) %>% 
  apply(3, colMeans)

graph_input = graph_probs %>% 
  as_data_frame() %>% 
  cbind(subject_time) %>% 
  gather("key", "value", - subject, -t) %>% 
  mutate(
    symptom = gsub("[[:digit:]]*", "", key),
    severity = as.numeric(gsub("[[:alpha:]]*", "", key))
  )

saveRDS(graph_input, file = "graph_input.rds")

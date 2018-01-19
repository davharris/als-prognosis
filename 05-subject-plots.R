source("01-import.R")
source("02-munge.R")
library(brms)

if (!exists("fit")) {
  fit = readRDS("fit.rds")
}


# Slopes ------------------------------------------------------------------

ranefs = ranef(fit)[[1]]
ranefs = ranefs[ , , grep("elapsed", dimnames(ranefs)[[3]])]
dimnames(ranefs)[[3]] = gsub("_elapsed", "", dimnames(ranefs)[[3]])
saveRDS(ranefs, "ranefs.rds")



# Symptom probabilities ---------------------------------------------------

times = seq(0, 2, length.out = 25)

subject_time = crossing(
  subject = unique(validation_data$subject), 
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



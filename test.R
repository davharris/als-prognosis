source("01-import.R")
library(rstan)

# 
history = history %>% 
  distinct(subject_id, Onset_Delta)

frs = frs %>% 
  select(1:13) %>%
  select(-starts_with("Q5")) %>% 
  inner_join(distinct(history), by = "subject_id") %>% 
  na.omit() %>% 
  slice(1:1000)

data = list(
  N = nrow(frs),
  N_subjects = length(unique(frs$subject_id)),
  subject_index = as.integer(factor(frs$subject_id)),
  K = 5,
  severity = 5 - floor(frs$Q10_Respiratory),
  id = frs$subject_id,
  t = frs$ALSFRS_Delta - frs$Onset_Delta
)

model = stan_model("symptoms.stan")

fit = sampling(model, data = data, refresh = 100, chains = 2, cores = 2)


my_matplot = function(x, type = "l", lty = 1, ...) {
  matplot(x, type = type, lty = lty, ...)
}

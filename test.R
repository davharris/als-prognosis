source("01-import.R")
library(rstan)

frs = frs %>% 
  select(1:13) %>%
  select(-starts_with("Q5")) %>% 
  na.omit()

data = list(
  N = nrow(frs),
  K = 5,
  y = 5 - floor(frs$Q1_Speech),
  id = frs$subject_id,
  t = frs$ALSFRS_Delta
)

stop()

model = stan_model("symptoms.stan")

s = sampling(model, data = data, refresh = 100, chains = 2)

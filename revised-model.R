library(rstan)
source("01-import.R")

new_frs = frs %>% 
  mutate(Q5_Cutting = ifelse(is.na(Q5a_Cutting_without_Gastrostomy), 
                             Q5b_Cutting_with_Gastrostomy, 
                             Q5a_Cutting_without_Gastrostomy)
  ) %>% 
  select(subject_id, ALSFRS_Delta, matches("^.[[:digit:]]*_")) %>% 
  gather(key = Symptom, value = Function, -subject_id, -ALSFRS_Delta) %>% 
  drop_na() %>% 
  filter(Function %% 1 == 0)

df = history %>% 
  distinct(subject_id, Onset_Delta) %>% 
  drop_na() %>% 
  inner_join(new_frs, "subject_id") %>% 
  mutate(elapsed_months = (ALSFRS_Delta - Onset_Delta) / 365.24 * 12) %>% 
  select(-Onset_Delta, -ALSFRS_Delta) %>% 
  arrange(subject_id, Symptom)


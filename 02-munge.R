set.seed(1)

patient_ids = readLines("PRO-ACT/Archive/ALS_Prize_slopes/slopes.train") %>% 
  gsub("^.*:(.*)\t.*", "\\1", .)

history = history %>% 
  distinct(subject_id, Onset_Delta)

# Combine 5a and 5b into one question, then drop the originals
frs = frs %>% 
  select(1:13) %>%
  mutate(Q5_Cutting = ifelse(is.na(Q5a_Cutting_without_Gastrostomy), 
                             Q5b_Cutting_with_Gastrostomy, 
                             Q5a_Cutting_without_Gastrostomy)
  ) %>% 
  select(-Q5a_Cutting_without_Gastrostomy, -Q5b_Cutting_with_Gastrostomy) %>% 
  filter(subject_id %in% patient_ids) %>% 
  inner_join(distinct(history), by = "subject_id") %>% 
  na.omit() %>% 
  mutate(elapsed = (ALSFRS_Delta - Onset_Delta) / 365.24)

frs = frs[ , sort(colnames(frs))]
colnames(frs) = gsub("Q..?_", "", colnames(frs))
colnames(frs) = gsub("_.*$", "", colnames(frs))

responses = colnames(frs)[4:13]


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

saveRDS(validation_data, "validation_data.rds")

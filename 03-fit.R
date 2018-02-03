library(brms, quietly = TRUE)
set.seed(1)

fit = brm(
  bf(
    cbind("Speech", "Salivation", "Swallowing", "Handwriting", "Cutting", "Dressing", 
          "Turning", "Walking", "Climbing", "Respiratory") ~ 
      elapsed + 
      (elapsed | s | subject)
  ) + 
    set_rescor(FALSE), 
  family = cumulative(),
  prior = set_prior("student_t(3, 0, 25)", class = "b"),
  data = training_data,
  chains = 2,
  cores = 2,
  refresh = 50,
  save_model = "brm.stan"
)

saveRDS(fit, file = "fit.rds")

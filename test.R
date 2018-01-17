source("01-import.R")
library(brms, quietly = TRUE)
theme_set(theme_default())


history = history %>% 
  distinct(subject_id, Onset_Delta)

frs = frs %>% 
  select(1:13) %>%
  select(-starts_with("Q5")) %>% 
  inner_join(distinct(history), by = "subject_id") %>% 
  na.omit() %>% 
  mutate(elapsed = (ALSFRS_Delta - Onset_Delta) / 365.24) %>% 
  slice(1:1000)


colnames(frs) = gsub("Q..?_", "", colnames(frs))
colnames(frs) = gsub("_.*$", "", colnames(frs))

responses = c("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
              "Turning", "Walking", "Climbing", "Respiratory")


severity = floor(5 - frs[ , colnames(frs) %in% responses])


data = cbind(severity, select(frs, subject, elapsed))

fit = brm(
  bf(
    cbind("Swallowing", "Respiratory", "Walking") ~ elapsed + (elapsed | s | subject)
  ) + 
    set_rescor(FALSE), 
  family = cumulative(),
  data = data,
  chains = 2,
  cores = 2,
  refresh = 50,
  save_model = "brm.stan"
)

saveRDS(fit, file = "fit.rds")

#fit = readRDS("fit.rds")

fit

cors = colMeans(as.matrix(fit$fit, "cor_1"))
linpred = posterior_linpred(fit, transform = TRUE)
p = apply(linpred[,,1:5], 3, colMeans)
plot(data$elapsed, p[,1])
mean(log(p[cbind(1:nrow(p),data[["Swallowing"]])]))
log(.2)


times = seq(0, max(data$elapsed), 1/365)

id = sample(data$subject, 1)
#id = "b"
linpred_baseline = posterior_linpred(
  fit, transform = TRUE, 
  newdata = data.frame(elapsed = times, subject = id),
  allow_new_levels = TRUE
)

symptom_names = names(fit$formula$forms)
symptom = 3


linpred_symptom = linpred_baseline[,,grep(symptom_names[symptom], dimnames(linpred_baseline)[[3]])]

subject_data = filter(data, subject == id)

color_order = c(5, 7, 3, 6, 8)

reshape2::melt(apply(linpred_symptom, 3, colMeans)) %>% 
  ggplot(aes(x = Var1 / 365, y = value, color = Var2, fill = Var2)) +
  geom_area(position = "identity", alpha = 0.1) + 
  geom_line(size = 1, alpha = 0.5)  + 
  colorblindr::scale_color_OkabeIto(order = color_order, use_black = TRUE) + 
  colorblindr::scale_fill_OkabeIto(order = color_order, use_black = TRUE) + 
  cowplot::theme_cowplot() +
  xlab("Years") +
  ylab("Probability") +
  ylim(c(0, 1.01)) + 
  coord_cartesian(expand = FALSE)

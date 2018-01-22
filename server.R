library(tidyverse)
library(cowplot)
graph_input = read_rds("graph_input.rds")
validation_data = read_rds("validation_data.rds")
ranefs = read_rds("ranefs.rds")

id = sample(unique(validation_data$subject), 1)

colors = c("#0072B2", "#CC79A7", "#009E73", "#D55E00", "#000000")

bulbar_symptoms = c("Speech", "Salivation", "Swallowing")
motor_symptoms = c("Handwriting", "Dressing", "Turning", "Walking", "Climbing")
respiratory_symptoms = c("Respiratory")


one_symptom_timeline = function(subject, symptom, x){
  graph_input %>% 
    filter(subject == !!subject, symptom == !!symptom) %>% 
    ggplot(
      aes(
        x = t,
        y = value,
        fill = factor(5 - severity, levels = 4:0)
      )
    ) + 
    geom_area() + 
    scale_fill_brewer(type = "seq", palette = "OrRd") + 
    xlab("Years") +
    ylab("Probability") +
    ylim(c(0, 1.01)) + 
    coord_cartesian(expand = FALSE) + 
    geom_vline(xintercept = ifelse(is.null(x), 0, x))
}


plot_speeds = function(subject) {
  as.data.frame(t(ranefs[subject, , ])) %>% 
    rownames_to_column("symptom") %>% 
    ggplot(aes(x = Estimate, y = symptom)) +
    geom_point() +
    geom_errorbarh(aes(xmin = Estimate - Est.Error, xmax = Estimate + Est.Error),
                   height = .25) +
    xlim(range(ranefs[ , c("2.5%ile", "97.5%ile"), ])) +
    geom_vline(xintercept = 0, color = alpha(1, .25)) + 
    ylab("") +
    xlab("Slower               Faster") +
    ggtitle(paste("Relative decline rates for subject", subject))
}

make_lines = function(subject, symptoms, title){
  graph_input %>% 
    filter(subject == !!subject, symptom %in% symptoms) %>% 
    group_by(t, symptom) %>% 
    summarize(prediction = sum((5-severity) * value)) %>% 
    ggplot(aes(x = t, y = prediction, color = symptom)) +
    geom_line() +
    ylim(c(0, 4)) +
    coord_cartesian(expand = FALSE) +
    ggtitle(title)
}

# Define server logic required to generate and plot data
shinyServer(function(input, output) {
  x = NULL
  makeReactiveBinding("x")
  observeEvent(input$symptom_hover$x, {x <<- input$symptom_hover$x})
  
  output$distPlot <- renderPlot({
    one_symptom_timeline(input$subject_ID, input$symptom, x)
  })
  output$speeds = renderPlot({
    plot_speeds(input$subject_ID)
  })
  output$lines = renderPlot({
    cowplot::plot_grid(
      make_lines(input$subject_ID, bulbar_symptoms, title = "Bulbar (mouth/throat)"),
      make_lines(input$subject_ID, motor_symptoms, title = "Motor"),
      make_lines(input$subject_ID, respiratory_symptoms, title = "Respiratory"),
      ncol = 3
    )
  })
  output$Symptoms = renderText(paste0("Subject ", input$subject_ID, ": ", input$symptom))
})

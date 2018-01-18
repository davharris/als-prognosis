library(tidyverse)
graph_input = read_rds("graph_input.rds")
validation_data = read_rds("validation_data.rds")

id = sample(unique(validation_data$subject), 1)

colors = c("#0072B2", "#CC79A7", "#009E73", "#D55E00", "#000000")

one_symptom_timeline = function(subject, symptom){
  graph_input %>% 
    filter(subject == !!subject, symptom == !!symptom) %>% 
    ggplot(
      aes(
        x = t,
        y = value,
        color = factor(severity),
        fill = factor(severity)
      )
    ) + 
    geom_area(position = "identity", alpha = 0.1) + 
    geom_line(size = 1, alpha = 0.5)  + 
    scale_color_manual(values = colors) + 
    scale_fill_manual(values = colors) + 
    cowplot::theme_cowplot() +
    xlab("Years") +
    ylab("Probability") +
    ylim(c(0, 1.01)) + 
    coord_cartesian(expand = FALSE)
}



# Define server logic required to generate and plot data
shinyServer(function(input, output) {
  output$distPlot <- renderPlot({
    one_symptom_timeline(input$subject_ID, input$symptom)
  })
  output$Symptoms = renderText(paste0("Subject ", input$subject_ID, ": ", input$symptom))
})

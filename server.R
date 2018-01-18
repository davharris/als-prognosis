source("01-import.R")
source("02-munge.R")


graph_input = read_rds("graph_input.rds")

id = sample(unique(validation_data$subject), 1)

color_order = c(5, 7, 3, 6, 8)

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
    colorblindr::scale_color_OkabeIto(order = color_order, use_black = TRUE) + 
    colorblindr::scale_fill_OkabeIto(order = color_order, use_black = TRUE) + 
    cowplot::theme_cowplot() +
    xlab("Years") +
    ylab("Probability") +
    ylim(c(0, 1.01)) + 
    coord_cartesian(expand = FALSE)
}



# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  
  # Expression that generates a plot of the distribution. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #
  output$distPlot <- renderPlot({
    one_symptom_timeline(input$subject_ID, input$symptom)
  })
  output$Symptoms = renderText(paste("Subject", input$subject_ID, "Symptom", input$symptom))
})

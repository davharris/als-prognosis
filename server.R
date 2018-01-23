library(tidyverse)
library(cowplot)
graph_input = read_rds("graph_input.rds")
validation_data = read_rds("validation_data.rds")
#ranefs = read_rds("ranefs.rds")

descriptions = yaml::yaml.load_file("frs.yaml")

id = sample(unique(validation_data$subject), 1)

font_size = 18

colors = c("#000000", "#0072B2", "#CC79A7", "#009E73", "#D55E00")

bulbar_symptoms = c("Speech", "Salivation", "Swallowing")
motor_symptoms = c("Handwriting", "Dressing", "Turning", "Walking", "Climbing")
respiratory_symptoms = c("Respiratory")


one_symptom_timeline = function(subject, symptom, x){
  df = graph_input %>% 
    filter(subject == !!subject, symptom == !!symptom)
  
  df = df %>% 
    mutate(Function = paste0(5 - severity, ": ", round(value * 100), "%")) %>% 
    mutate(Function = gsub(" 0%", " <1%", Function)) %>% 
    filter(near(t, x)) %>% 
    select(severity, Function) %>% 
    inner_join(df, by = c("severity"))
  
  df %>% 
    ggplot(
      aes(
        x = t,
        y = value,
        fill = Function
      )
    ) + 
    geom_area() + 
    scale_fill_brewer(type = "seq", palette = "OrRd", direction = -1) + 
    xlab("Years") +
    ylab("Probability") +
    ylim(c(0, 1.01)) + 
    coord_cartesian(expand = FALSE) + 
    theme_cowplot(font_size = font_size) +
    theme(legend.position = c(x / 2, .5), 
          legend.background = element_rect(fill = "white"), 
          legend.margin = margin(4,4,4,4),
          legend.justification = ifelse(x < 1, 0, 1)
    ) +
    xlim(c(0, 2)) +
    guides(fill=guide_legend(title=paste("Probable scores\nafter", x * 12, "months"))) + 
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
    ggtitle(paste("Relative decline rates for subject", subject)) +
    theme_cowplot(font_size = font_size)
}

make_lines = function(subject, symptoms, title){
  df = if (identical(symptoms, "all")) {
    graph_input %>% 
      mutate(symptom = "Total")
  } else {
    graph_input %>% 
      filter(symptom %in% symptoms)
  }
  ymax = ifelse(identical(symptoms, "all"), 40, 4)
  
  df %>% 
    filter(subject == !!subject) %>% 
    group_by(t, symptom) %>% 
    summarize(`expected function` = sum((5-severity) * value)) %>% 
    ggplot(aes(x = t, y = `expected function`, color = symptom)) +
    geom_line(size = 1) +
    ylim(c(0, ymax)) +
    coord_cartesian(expand = FALSE) +
    ggtitle(title) +
    theme(legend.position="bottom") + 
    xlab("Time (years)") +
    scale_color_manual(values = colors) +
    theme_cowplot(font_size = font_size)
}

# Define server logic required to generate and plot data
shinyServer(function(input, output) {
  x = 1
  makeReactiveBinding("x")
  observeEvent(input$symptom_hover$x, {x <<- round(input$symptom_hover$x * 12) / 12})
  
  output$distPlot <- renderPlot(
    {
      one_symptom_timeline(input$subject_ID, input$symptom, x)
    }
  )
  output$speeds = renderPlot({
    plot_speeds(input$subject_ID)
  })
  output$lines = renderPlot({
    cowplot::plot_grid(
      make_lines(input$subject_ID, bulbar_symptoms, title = "Bulbar (mouth/throat) progression"),
      make_lines(input$subject_ID, motor_symptoms, title = "Motor progression"),
      make_lines(input$subject_ID, respiratory_symptoms, title = "Respiratory progression"),
      make_lines(input$subject_ID, "all", title = "Total progression"),
      ncol = 2
    )
  },
  height = 600
  )
  output$Symptoms = renderText(paste0("Subject ", input$subject_ID, ": ", input$symptom))
  output$description = renderUI({
    desc_symptom = ifelse(input$symptom == "Respiratory", "Dyspnea", input$symptom)
    desc_symptom = grep(desc_symptom, names(descriptions), value = TRUE)
    description = c(
      paste0("<b>", desc_symptom, "</b>", ":"), 
      rev(paste(4:0, descriptions[[desc_symptom]]))
    )
    HTML(paste(description, collapse="<br/>"))
  })
})

library(ggplot2)
library(dplyr)
library(cowplot)
graph_input = read_rds("graph_input.rds")
validation_data = read_rds("validation_data.rds")
subject_data = read_csv("app_demographics.csv")
#ranefs = read_rds("ranefs.rds")

descriptions = yaml::yaml.load_file("frs.yaml")

id = sample(unique(validation_data$subject), 1)

font_size = 18

colors = c("#000000", "#0072B2", "#CC79A7", "#009E73", "#D55E00")

symptoms = colnames(validation_data[1:10])

bulbar_symptoms = sort(c("Speech", "Salivation", "Swallowing"), decreasing = TRUE)
motor_symptoms = sort(c("Handwriting", "Cutting", "Dressing", "Turning", "Walking", "Climbing"), decreasing = TRUE)
respiratory_symptoms = sort(c("Respiratory"), decreasing = TRUE)

symptom_list = list(Bulbar = bulbar_symptoms, Motor = motor_symptoms, Respiratory = respiratory_symptoms)

graph_input = graph_input %>% 
  mutate(
    symptom_type = factor(
      symptom %in% bulbar_symptoms + 2 * (symptom %in% motor_symptoms), 
      labels = c("Resp.", "Bulbar", "Motor")
    )
  )


one_symptom_timeline = function(subject, symptom, x){
  df = graph_input %>% 
    filter(subject == !!subject, symptom == !!symptom)
  
  df = df %>% 
    mutate(Function = paste0(5 - severity, ": ", round(value * 100), "%")) %>% 
    mutate(Function = gsub(" 0%", " <1%", Function)) %>% 
    filter(near(t * 12, x)) %>% 
    select(severity, Function) %>% 
    inner_join(df, by = c("severity"))
  
  df %>% 
    ggplot(
      aes(
        x = 12 * t,
        y = value,
        fill = Function
      )
    ) + 
    geom_area() + 
    scale_fill_brewer(type = "seq", palette = "OrRd", direction = -1) + 
    xlab("Time (months)") +
    ylab("Probability") +
    ylim(c(0, 1.01)) + 
    coord_cartesian(expand = FALSE) + 
    theme_cowplot(font_size = font_size) +
    theme(legend.position = c(x / 2 / 12, .5), 
          legend.background = element_rect(fill = "white"), 
          legend.margin = margin(4,4,4,4),
          legend.justification = ifelse(x < 12, 0, 1)
    ) +
    scale_x_continuous(breaks = seq(0, 24, 3)) + 
    guides(fill=guide_legend(title=paste("Probable scores\nafter", x, "months"))) + 
    geom_vline(xintercept = ifelse(is.null(x), 0, x)) 
}

make_all = function(subject){
  graph_input %>% 
    filter(subject == !!subject) %>% 
    group_by(t, symptom, symptom_type) %>% 
    summarize(`expected score` = sum((5-severity) * value)) %>% 
    ggplot(aes(x = 12 * t, y = forcats::fct_rev(factor(symptom)), fill = `expected score`)) +
    geom_raster() +
    coord_cartesian(expand = FALSE) +
    xlab("Time (months)") +
    scale_x_continuous(breaks = seq(0, 24, 3)) + 
    ylab("") +
    scale_fill_distiller(palette = "OrRd", limits = c(0, 4)) +
    theme_cowplot(font_size = font_size) +
    # geom_text(aes(label = format(round(`expected score`, 1), nsmall = 1))) + 
    facet_grid(symptom_type ~ ., scales = "free", shrink = TRUE, space = "free_y")
}

get_symptom = function(group, y){
  out = symptom_list[[group]][round(y)]
  if (is.null(out)) {
    "Respiratory"
  } else {
    out
  }
}




# Define server logic required to generate and plot data
shinyServer(function(input, output, session) {
  
  observeEvent(input$showTab, {
    symptom <<- get_symptom(input$showTab$panelvar1, input$showTab$y)
    updateSelectInput(session, "symptom", selected = symptom)
    output$y <<- renderText(input$showTab$y)
  })
  observeEvent(input$symptom, {
    symptom <<- input$symptom
  })
  
  observeEvent(input$showTab, {
    showTab(inputId = "tabs", target = "Daily Tasks", select = TRUE)
  })
  
  x = 12
  makeReactiveBinding("x")
  
  symptom = "respiratory"
  makeReactiveBinding("symptom")
  
  observeEvent(input$symptom_hover$x, {x <<- round(input$symptom_hover$x)})
  
  output$tag = renderText("Forecasting multi-symptom progression of Lou Gehrig's disease")
  
  output$subject_summary = renderText(
    {
      subject_info = filter(subject_data, subject == input$subject_ID)
      paste0(
        "Subject ", 
        subject_info$subject, 
        " is a ", 
        subject_info$Age, 
        " year old ",
        subject_info$Sex,
        ". ",
        ifelse(subject_info$Sex == "Male", "He", "She"),
        " began experiencing ",
        tolower(strsplit(subject_info$Site_of_Onset, " +")[[1]][[2]]),
        "-onset ALS ",
        round(subject_info$elapsed),
        " months ago. "
      )
    }
  )
  
  output$distPlot <- renderPlot(
    {
      one_symptom_timeline(input$subject_ID, symptom, x)
    }
  )
  output$speeds = renderPlot({
    plot_speeds(input$subject_ID)
  })
  output$all_symptoms = renderPlot({
    make_all(input$subject_ID)
  },
  height = 600
  )
  output$h3 = renderText(paste0("Subject ", input$subject_ID, ": ", symptom))
  output$description = renderUI({
    desc_symptom = ifelse(symptom == "Respiratory", "Dyspnea", symptom)
    desc_symptom = grep(desc_symptom, names(descriptions), value = TRUE)
    description = c(
      paste0("<b>", desc_symptom, "</b>", ":"), 
      rev(paste(4:0, descriptions[[desc_symptom]]))
    )
    HTML(paste(description, collapse="<br/>"))
  })
  output$instructions1 = renderText("This tab provides an overview of the subject's progression. Switch to the \"Daily Tasks\" tab for more detail on their projected ability to perform individual tasks.")
  output$instructions2 = renderText("Move your mouse to a time in the future to see likely scores")
})

library(shiny)
library(readr)

subject_ids = read_csv("subject_ids.csv", col_types = cols(x = col_integer()))[[1]]

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("ALS Prognosis Predictor"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput("subject_ID", "Choose a subject", subject_ids, selected = 13165L),
    width = 2
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    
    tabsetPanel(type = "tabs",
                id = "tabs",
                tabPanel(
                  "Summary",
                  textOutput("instructions1"),
                  plotOutput("all_symptoms", height = "600px", click = "showTab")
                ),
                tabPanel(
                  "Symptoms", 
                  selectInput("symptom", 
                              "Choose a symptom", 
                              c("Speech", "Salivation", "Swallowing", "Handwriting", "Cutting", "Dressing", 
                                "Turning", "Walking", "Climbing", "Respiratory")),
                  h3(textOutput("Symptoms")), 
                  textOutput("instructions2"),
                  plotOutput("distPlot", hover = hoverOpts("symptom_hover", delay = 50)),
                  htmlOutput("description"),
                  textOutput("y")
                )
    ),
    width = 10
  )
))
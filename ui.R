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
                tabPanel(
                  "Summary",
                  plotOutput("lines", height = "600px")
                ),
                tabPanel(
                  "Symptoms", 
                  selectInput("symptom", 
                              "Choose a symptom", 
                              c("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
                                "Turning", "Walking", "Climbing", "Respiratory")),
                  h3(textOutput("Symptoms")), 
                  plotOutput("distPlot", hover = hoverOpts("symptom_hover", delay = 50)),
                  htmlOutput("description")
                )
    ),
    width = 10
  )
))
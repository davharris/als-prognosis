library(shiny)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("ALS Prognosis Predictor"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput("subject_ID", "Choose a subject", 1:3)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    
    tabsetPanel(type = "tabs",
                tabPanel("Summary", plotOutput("distPlot")),
                tabPanel(
                  "Symptoms", 
                  selectInput("symptom", "Choose a symptom", 1:9),
                  h3(textOutput("Symptoms")))
    )
  )
))


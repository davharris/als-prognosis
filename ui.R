library(shiny)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("ALS Prognosis Predictor"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput("subject_ID", "Choose a subject", c(649L, 2956L, 3085L, 5936L, 8480L, 13165L, 15511L, 18424L, 24428L, 
                                                    24571L))
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    
    tabsetPanel(type = "tabs",
                tabPanel("Summary"),
                tabPanel(
                  "Symptoms", 
                  selectInput("symptom", 
                              "Choose a symptom", 
                              c("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
                                "Turning", "Walking", "Climbing", "Respiratory")),
                  h3(textOutput("Symptoms")), 
                  plotOutput("distPlot")
                )
    )
  )
))


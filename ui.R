library(shiny)

subject_ids = c(649L, 2956L, 3085L, 5936L, 8480L, 13165L, 15511L, 18424L, 24428L, 24571L)

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
                  plotOutput("lines", height = "800px"),
                  br(),
                  br(),
                  plotOutput("speeds")
                ),
                tabPanel(
                  "Symptoms", 
                  selectInput("symptom", 
                              "Choose a symptom", 
                              c("Speech", "Salivation", "Swallowing", "Handwriting", "Dressing", 
                                "Turning", "Walking", "Climbing", "Respiratory")),
                  h3(textOutput("Symptoms")), 
                  plotOutput("distPlot", hover = hoverOpts("symptom_hover", delay = 50))
                )
    ),
    width = 10
  )
))
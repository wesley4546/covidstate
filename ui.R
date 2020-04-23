library(shiny)

#Sources data file
source("R/covid_source_file.R", local = TRUE)

ui <- fluidPage(
  h1("COVID-19 Death Tracker"),
  sidebarLayout(
    
    sidebarPanel(
      checkboxGroupInput(inputId = "state_filter", "State",
                         choices = unique(state_longer_elections$state), selected = c("Florida", "California")),
      
      actionButton(inputId = "reset_filter", "Reset Filter")
    ),
    
    mainPanel(plotOutput("lineplot"))
    
  )
)

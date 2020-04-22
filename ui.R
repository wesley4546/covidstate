library(shiny)

source("R/covid_source_file.R", local = TRUE)

ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      checkboxGroupInput(inputId = "state_filter", "State",
                         choices = unique(state_longer_elections$state), selected = c("Florida", "California"))
    ),
    
    mainPanel(plotOutput("lineplot"))
    
  )
)

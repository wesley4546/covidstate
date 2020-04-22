library(shiny)
library(ggplot2)

source(here::here("R","covid_source_file.R"))


ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      checkboxGroupInput(inputId = "state_filter", "State",
                         choices = unique(state_longer_elections$state), selected = c("Florida", "California"))
    ),
    
    mainPanel(plotOutput("lineplot"))
    
  )
)

server <- function(input, output){
  
  
  filterdata <- reactive({
    
    state_longer_elections %>% 
      filter(state %in% input$state_filter)
    
  })
  
  output$lineplot <- renderPlot({
    
    ggplot(filterdata(), aes(x=daycount,y=scaled_deaths, group = state, color = factor(party, c("republican", "democrat")))) +
      geom_line() + 
      theme(legend.title = element_blank()) +
      labs(
        title = "Deaths of COVID-19 by State" ,
        subtitle = "Scaled to population of state - Colored by vote in 2016 Election (Popular)",
        x = "Day Count",
        y = "Scaled Count"
      )
    
    
    
  }, height = 700, width = 1000)
}

shinyApp(ui = ui, server = server)



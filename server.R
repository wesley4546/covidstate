library(shiny)
library(ggrepel)

#Sources data file
source("R/covid_source_file.R", local = TRUE)


server <- function(input, output, session) {
  
  # Variables ---------------------------------------------------------------
  
  # Creates variable for selected states 
  states_selected <- reactive({
    input$state_filter
  })
  
  #Filters state_longer_elections to the states selected from UI
  filterdata <- reactive({
    state_longer_elections %>%
      filter(state %in% states_selected())
  })
  
  #Retrieves max values in order to do labeling on ggplot graph
  toplabels <- reactive({
    filterdata() %>%
      filter(scaled_deaths_per_unit == max(scaled_deaths_per_unit))
  })
  
  
  # Buttons -----------------------------------------------------------------
  
  # Reset Filter Button
  observeEvent(input$reset_filter, {
    updateCheckboxGroupInput(session, "state_filter", selected= c("Florida", "California"))
  })

  
  # Outputs -----------------------------------------------------------------
  
  output$lineplot <- renderPlot({
    #Main graph
    p <- ggplot(
      filterdata(),
      aes(
        x = daycount,
        y = scaled_deaths_per_unit,
        color = factor(party, c("republican", "democrat")),
        group = state,
      )
    ) +
      labs(
        title = "Deaths of COVID-19 by State" ,
        subtitle = "Scaled to population of state - Colored by vote in 2016 Election (Popular)",
        x = "Day Count",
        y = "Deaths per 100,000 People"
      ) +
      theme(
        legend.title = element_blank(),
        legend.position = "bottom",
        plot.margin = unit(c(.5, 5, 1, 1), "cm") # Margins big so theres no cutoff
      ) +
      geom_label_repel( #This allows the labeling of the states
        data = toplabels(),
        aes(
          x = daycount,
          y = scaled_deaths_per_unit,
          label = state,
          group = state, 
        ), 
        xlim = c((max(toplabels()$daycount) + 2.5), (max(toplabels()$daycount) + 2.5)), #This offsets the labels
        show.legend = FALSE
      ) +
      geom_line() +
      geom_point()
    
    #This allows for clipping of labels outside of plot
    gt <- ggplotGrob(p)
    gt$layout$clip[gt$layout$name == "panel"] <- "off"
    grid.draw(gt)
    
    
    
  }, height = 700, width = 1000)
}
library(shiny)
library(ggrepel)

#Sources data file
source("R/covid_source_file.R", local = TRUE)


server <- function(input, output, session) {
  
  # Variables ---------------------------------------------------------------
  
  main_data <-reactive({
    state_longer_elections
  })
  
  
  # Creates variable for selected states 
  states_selected <- reactive({
    input$state_filter
  })
  
  #Filters main_data to the states selected from UI
  filterdata <- reactive({
    main_data() %>%
      filter(state %in% states_selected())
  })
  
  #Retrieves max values in order to do labeling on ggplot graph
  toplabels <- reactive({
    data_to_label <- filterdata() %>%
      filter(scaled_deaths_per_unit == max(scaled_deaths_per_unit))
  })
  
  
  
  # Button Actions -----------------------------------------------------------------
  
  # reset_button action
  observeEvent(input$reset_button, {
    updateCheckboxGroupInput(session, "state_filter", selected = c("Florida", "New York"))
    updateCheckboxInput(session, "label_button", value = TRUE)
  })
  
  # all_democrat_button action
  observeEvent(input$all_democrat_button, {
    updateCheckboxGroupInput(session, "state_filter", selected = unique(c(state_longer_elections %>% 
                                                                            filter(party == "democrat"))$state))
    updateCheckboxInput(session, "label_button", value = FALSE)
  })
  # all_republican_button action
  observeEvent(input$all_republican_button, {
    updateCheckboxGroupInput(session, "state_filter", selected = unique(c(state_longer_elections %>% 
                                                                            filter(party == "republican"))$state))
    updateCheckboxInput(session, "label_button", value = FALSE)
  })
  
  # all_state_button action
  observeEvent(input$all_state_button, {
    updateCheckboxGroupInput(session, "state_filter", selected = unique(state_longer_elections$state))
    updateCheckboxInput(session, "label_button", value = FALSE )
  })
  
  # Outputs -----------------------------------------------------------------
  
  
  # lineplot 
  output$lineplot <- renderPlot({
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
      geom_line() +
      geom_point()
    
    # label_button logical expression
    if(input$label_button == TRUE){
      p <- p + geom_label_repel( # This allows the labeling of the states
        data = toplabels(),
        aes(
          x = daycount,
          y = scaled_deaths_per_unit,
          label = state,
          group = state, 
        ), 
        xlim = c((max(toplabels()$daycount) + 2.5), (max(toplabels()$daycount) + 2.5)), #This offsets the labels
        show.legend = FALSE)
    }
    # facet_button logical expression
    if(input$facet_button == TRUE){
      p <- p + facet_wrap(~party)
      updateCheckboxInput(session, "label_button", value = FALSE)
    }
    
    #This allows for clipping of labels outside of plot
    gt <- ggplotGrob(p)
    gt$layout$clip[gt$layout$name == "panel"] <- "off"
    grid.draw(gt)
    
    
    #downloadData Button action
    output$downloadData <- downloadHandler(
      filename = paste("covid_death_state_election", ".csv", sep = ""),
      content = function(file) {
        write.csv(main_data(), file, row.names = FALSE)
      }
    )
    
    output$summary <- renderPrint({
      summary(filterdata())
      })
    
    output$table <- renderTable({
      filterdata()
    })

  }, height = 700, width = 1000)
}
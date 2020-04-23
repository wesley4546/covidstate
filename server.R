library(shiny)
library(ggrepel)


source("R/covid_source_file.R", local = TRUE)


server <- function(input, output) {
  filterdata <- reactive({
    state_longer_elections %>%
      filter(state %in% input$state_filter)
    
  })
  
  toplabels <- reactive({
    filterdata() %>%
      filter(scaled_deaths_per_unit == max(scaled_deaths_per_unit))
  })
  
  output$lineplot <- renderPlot({
    
    ggplot(
      filterdata(),
      aes(
        x = daycount,
        y = scaled_deaths,
        color = factor(party, c("republican", "democrat")),
        group = state,
      )
    ) +
      labs(
        title = "Deaths of COVID-19 by State" ,
        subtitle = "Scaled to population of state - Colored by vote in 2016 Election (Popular)",
        x = "Day Count",
        y = "Scaled Count"
      ) +
      theme(
        legend.title = element_blank(),
        legend.position = "bottom",
        plot.margin = unit(c(.5, 3.5, 1, 1), "cm")
      ) +
      geom_label_repel(data = toplabels(),
                       aes(
                         x = daycount,
                         y = scaled_deaths,
                         label = state,
                         group = state,
                       )) +
      geom_line()
    
    # gt <- ggplotGrob(p)
    # gt$layout$clip[gt$layout$name == "panel"] <- "off"
    # grid.draw(gt)
    
    
    
  }, height = 700, width = 1000)
}
library(shiny)
library(detourr)
library(crosstalk)
library(palmerpenguins)

penguins <- na.omit(palmerpenguins::penguins)
tour_data <- penguins[, c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g", "species")]

shared_penguins <- SharedData$new(tour_data)

ui <- fluidPage(
  titlePanel("Linked Brushing: Grand Tour vs Little Tour"),
  
  fluidRow(
    column(
      6, 
      h3("Grand Tour"),
      displayScatter2dOutput("tour1")
    ),
    column(
      6, 
      h3("Little Tour"),
      displayScatter2dOutput("tour2")
    )
  )
)

server <- function(input, output) {
  output$tour1 <- shinyRenderDisplayScatter2d({
    detour(shared_penguins, tour_aes(projection = -species, colour = species)) |>
      tour_path(grand_tour(2), fps = 60) |>  
      show_scatter(alpha = 1.0, axes = FALSE)
  })
  
  output$tour2 <- shinyRenderDisplayScatter2d({
    detour(shared_penguins, tour_aes(projection = -species, colour = species)) |>
      tour_path(little_tour(2), fps = 60) |>  
      show_scatter(alpha = 1.0, axes = FALSE)
  })
}

shinyApp(ui = ui, server = server)

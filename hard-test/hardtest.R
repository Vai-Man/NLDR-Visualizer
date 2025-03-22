required_packages <- c("shiny", "Rtsne", "ggplot2", "palmerpenguins", "dplyr", "bslib")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(Rtsne)
library(ggplot2)
library(palmerpenguins)
library(dplyr)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Penguin Data Analysis: t-SNE Projection"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Configuration Settings"),
      
      sliderInput("perplexity", "Perplexity:", min = 5, max = 50, value = 20, step = 5),
      sliderInput("eta", "Optimization Rate:", min = 10, max = 1000, value = 200, step = 10),
      sliderInput("max_iter", "Iteration Count:", min = 250, max = 2000, value = 1000, step = 250),
      sliderInput("point_size", "Marker Size:", min = 1, max = 5, value = 3, step = 0.5),
      sliderInput("opacity", "Transparency Level:", min = 0.2, max = 1, value = 0.7, step = 0.1),
      
      checkboxGroupInput("features", "Select Features for Analysis:", 
                         choices = c("Bill Length (mm)" = "bill_length_mm", 
                                     "Bill Depth (mm)" = "bill_depth_mm", 
                                     "Flipper Length (mm)" = "flipper_length_mm", 
                                     "Body Mass (g)" = "body_mass_g"),
                         selected = c("bill_length_mm", "bill_depth_mm", 
                                      "flipper_length_mm", "body_mass_g")),
      
      downloadButton("downloadPlot", "Download Visualization")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Projection Plot", plotOutput("tsne_plot")),
        tabPanel("Dataset Overview",
                 h4("About the Dataset"),
                 p("This dataset captures biological measurements of three penguin species."),
                 p("The t-SNE (t-Distributed Stochastic Neighbor Embedding) technique is applied to visualize high-dimensional data in a two-dimensional space."),
                 p("Each point represents an individual penguin, with color indicating species classification.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  penguins_data <- reactive({
    req(length(input$features) >= 2) 
    
    data <- na.omit(penguins[, c("species", input$features)])
    
    if (nrow(data) < 3) {
      showNotification("Insufficient data after filtering. Select additional features.", type = "error")
      return(NULL)
    }
    
    list(features = as.matrix(data[, input$features]), species = data$species)
  })
  
  output$tsne_plot <- renderPlot({
    data <- penguins_data()
    req(!is.null(data))
    
    max_perplexity <- floor((nrow(data$features) - 1) / 3)
    perplexity <- min(input$perplexity, max_perplexity)
    
    if (perplexity < input$perplexity) {
      showNotification(
        paste("Perplexity adjusted to", perplexity, "based on dataset size."),
        type = "warning"
      )
    }
    
    set.seed(123)
    tsne_result <- Rtsne(data$features, perplexity = perplexity, 
                         eta = input$eta, 
                         max_iter = input$max_iter, 
                         check_duplicates = FALSE, pca = TRUE, dims = 2)
    
    tsne_df <- data.frame(
      x = tsne_result$Y[, 1],
      y = tsne_result$Y[, 2],
      species = data$species
    )
    
    ggplot(tsne_df, aes(x = x, y = y, color = species)) +
      geom_point(size = input$point_size, alpha = input$opacity) +
      labs(
        title = paste("t-SNE Projection | Perplexity =", perplexity),
        x = "t-SNE Axis 1",
        y = "t-SNE Axis 2",
        color = "Penguin Species"
      ) +
      theme_minimal()
  })
  
  output$downloadPlot <- downloadHandler(
    filename = function() { paste("tsne_visualization_", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      png(file, width = 800, height = 600)
      data <- penguins_data()
      req(!is.null(data))
      
      tsne_result <- Rtsne(data$features, perplexity = min(input$perplexity, (nrow(data$features) - 1) / 3),
                           eta = input$eta, 
                           max_iter = input$max_iter, 
                           check_duplicates = FALSE, pca = TRUE, dims = 2)
      
      tsne_df <- data.frame(
        x = tsne_result$Y[, 1],
        y = tsne_result$Y[, 2],
        species = data$species
      )
      
      print(ggplot(tsne_df, aes(x = x, y = y, color = species)) +
              geom_point(size = input$point_size, alpha = input$opacity) +
              labs(
                title = paste("t-SNE Projection | Perplexity =", input$perplexity),
                x = "t-SNE Axis 1",
                y = "t-SNE Axis 2",
                color = "Penguin Species"
              ) +
              theme_minimal())
      dev.off()
    }
  )
}

shinyApp(ui, server)

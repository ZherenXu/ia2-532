library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(ggplot2)
library(plotly)
library(purrr)
library(tidyverse)

# Read data
df <- read_csv("data/vgsales.csv") %>%
  group_by(Year) %>%
  summarize(NA_Sales = mean(NA_Sales),
            EU_Sales = mean(EU_Sales),
            JP_Sales = mean(JP_Sales),
            Other_Sales = mean(Other_Sales),
            Global_Sales = mean(Global_Sales)) %>%
  mutate(Year = as.integer(Year))

# Setup app and layout/frontend
app = Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)
app$layout(
  dbcContainer(
    list(
      dccGraph(id='plot-area'),
      dccDropdown(
        id='col-select',
        value='NA_Sales',
        options = colnames(df)[2:6] %>%
          purrr::map(function(col) list(label = col, value = col))
      )
    )
  )
)

app$callback(
  output('plot-area', 'figure'),
  list(input('col-select', 'value')),
  function(ycol) {
    p <- ggplot(df, aes(x = Year, y = !!sym(ycol))) +
      geom_line(size=1)
    ggplotly(p)
  }
)

app$run_server(host = '0.0.0.0')
library(shiny)

## Initialization
library(htmltab)
library(plotly)
{## get AEX components names

        tabledata.url <- "https://en.wikipedia.org/wiki/AEX_index"
        AEX.components = htmltab(doc = tabledata.url, which=2, rm_nodata_cols = F)
        AEX.components.Symbol = paste0(AEX.components[['Ticker symbol']], '.AS')
        names(AEX.components.Symbol) =  paste0( AEX.components[['Company']], ' (', AEX.components[['ICB Sector']] ,')' )

}



#p("This app shows the performance of a particular AEX stock in comparison with the AEX index"),

# Define UI for dataset viewer application
shinyUI(fluidPage(

        # Application title
        headerPanel("AEX stock performance vs AEX"),
        p("This app shows the performance of a particular AEX stock in comparison with the AEX index."),
        p("The Sidebar shows a drop panel in which a stock can be selected and a sliderinput to specify the data range to view."),
        p("The Main Panel includes 4 tabs to view the results."),

        sidebarLayout(

                # Sidebar with controls to select a dataset and specify the number
                # of observations to view. The helpText function is also used to
                # include clarifying text. Most notably, the inclusion of a
                # submitButton defers the rendering of output until the user
                # explicitly clicks the button (rather than doing it immediately
                # when inputs change). This is useful if the computations required
                # to render output are inordinately time-consuming.
                sidebarPanel(

                        selectInput("stock_id", "AEX Stock:",
                                    AEX.components.Symbol),

                        # textInput("stock_id", "Type in stock ID to fetch data from Yahoo", e.g. "AALB.AS"),

                        # Specification of range within an interval
                        helpText("Specify Range (in % of data)"),
                        sliderInput("range", "Range:",
                                    min = 0, max = 100, value = c(0,100)),

                        helpText("Load Stockdata from Yahoo")

                        # submitButton("Update View")
                ),

                # Show a hierarchy of panels with plots
                mainPanel(

                        tabsetPanel(
                                tabPanel(
                                        "Table",
                                        tableOutput("tablehead"),
                                        tableOutput("tabletail"),
                                        p("AEX and stock data at beginning and end of range,")
                                ),

                                tabPanel(
                                        "Performance",
                                        plotOutput("timeseries"),
                                        p("The top chart is a normal cumulative return or wealth index chart that shows the
cumulative returns through time for each column."),
                                        p("The second chart shows the individual daily returns"),
                                        p("The third chart in the series is a drawdown or underwater chart, which shows the level
of losses from the last value of peak equity attained.")
                                ),

                                tabPanel("Stockplot",
                                         p("Stockprice over time with moving average data"),
                                         plotOutput("stockplot"),
                                         p("Use the Range slider to zoom in on specific time periods."),
                                         p("Bolingerband gives the range between the 14 days moving average and twice the standarddeviation.")

                                ),



                                tabPanel("Normalized graph", p("Normalized plot with index set at 100 at starting date."),
                                         plotlyOutput("normalizedplot"),
                                p("In some cases the stock graph does not appear,"),
                                p("in which case there is no stock data is available at the beginning of the chosen data range"),
                                p("In that case slide the range further to the right")
                                )

                        )

                )
        )))

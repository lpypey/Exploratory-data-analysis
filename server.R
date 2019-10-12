#
library(shiny)
library(quantmod)
library(PerformanceAnalytics)
library(plotly)


## Intialize AEX data
AdjustedPrice = 6
AEXall = getSymbols('^AEX', warnings = FALSE, auto.assign = FALSE)
AEX = na.fill(AEXall, fill = "extend")[,AdjustedPrice, drop=FALSE]


# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {

        # Return the requested dataset
        datasetInput <- reactive({


                stockdataall = getSymbols(input$stock_id, warnings = FALSE, auto.assign = FALSE)
                stockdata = na.fill(stockdataall, fill = "extend")[, AdjustedPrice, drop=FALSE]

                stockdata = merge (AEX, stockdata)

                no_of_datapoints = dim(stockdata)[1]

                min = input$range[1]/100 * no_of_datapoints
                max = input$range[2]/100 * no_of_datapoints

                # AdjustedPrice

                #out = stockdata
                out = stockdata[min:max,]

                return (out)
        })

        # generate a table
        output$tablehead <- renderTable({
                table <- data.frame(datasetInput())
                table$date <- rownames(table)
                table <- table[,c(3,1,2)]
                head(table,5)

        })

        # generate a table
        output$tabletail <- renderTable({
                table <- data.frame(datasetInput())
                table$date <- rownames(table)
                table <- table[,c(3,1,2)]
                tail(table,5)

        })

        # generate a plot
        output$timeseries <- renderPlot({

                AdjustedPrice <- datasetInput()


                Returns <- AdjustedPrice/lag(AdjustedPrice, 1) -1 # daily returns
                charts.PerformanceSummary(Returns)

        })



        # generate a plot
        output$stockplot <- renderPlot({

                #stockdataall1 = getSymbols(input$stock_id, warnings = FALSE, auto.assign = FALSE)
                #Index <- stockdataall1[,6]

                Index <- datasetInput()
                Index <- data.frame(Index)
                Index$datum <- as.Date(row.names(Index))

                Index <- na.locf(Index)
                colnames(Index)[2]<- "Index"
                Index$MA10 <- SMA(Index$Index, n=10)
                Index$MA20 <- SMA(Index$Index, n=20)
                Index$MA50 <- SMA(Index$Index, n=50)
                Index$MA200 <- SMA(Index$Index, n=200)
                #Index$RSI <- RSI(Index$Index, n=14)

                library(roll)
                summary(Index)
                sd(Index$Index,100)

                MATRIX <- matrix(Index$Index)
                Index$RollSD<-roll_sd(MATRIX,20, complete_ob = TRUE)

                Index$Bollingerplus <- Index$MA20+2*Index$RollSD
                Index$Bollingermin <- Index$MA20-2*Index$RollSD

                graph = ggplot()

                graph = graph + geom_line(data=Index, aes(x=datum, y=Index, group=1, colour="Index"))

                graph = graph + geom_line(data=Index, aes(x=datum, y=MA20,  group=1, colour="MA20"))
                graph = graph + geom_line(data=Index, aes(x=datum, y=MA50,  group=1, colour="MA50"))
                graph = graph + geom_line(data=Index, aes(x=datum, y=MA200,  group=1, colour="MA200"))

                graph = graph + geom_ribbon(data=Index, aes(x=datum, ymin=Bollingermin, ymax=Bollingerplus, fill="Bollingerband"), alpha="0.2")

                graph = graph + scale_x_date(breaks = function(x) seq.Date(from = min(x), to=max(x), by = "1 year"))

                graph = graph + theme(axis.text.x=element_text(angle = 45, hjust=1)) +ylab("index")

                graph
        })




        # generate a plot
        output$normalizedplot <- renderPlotly({

                table <- data.frame(datasetInput())
                table$date <- rownames(table)
                table <- table[,c(3,1,2)]
                stock <- input$stock_id

                x <- list( title="date", showgrid = T , zeroline = F , nticks = 20 , showline = T)
                y <- list( title="Normalized Index", showgrid = T , zeroline = F , nticks = 20 , showline = T)

                p=plot_ly(table, x = ~date, y = 100*table[,2]/table[,2][2], type = "scatter", mode = "lines", name="AEX") %>%
                       layout(title="Normalized plot", xaxis=x, yaxis=y)

                p = add_lines(p, x=~date, y=100*table[,3]/table[,3][2], name=stock)

                p


        })

})




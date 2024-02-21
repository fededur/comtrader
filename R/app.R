#' UN Comtrade shiny app
#'
#' @description run shiny app to query data from the UN Comtrade API.
#' @import shiny shinyWidgets dplyr
#' @importFrom magrittr %>%
#' @export
app <- function(...){

  ui <- div(style="width: auto !important; heightauto !important; background-color: #73737a",
            div(titlePanel("comtrader::app"), style='background-color: #454547;padding:12px 20px;color:white;'),
            fluidPage(
              div(sidebarLayout(
                div(sidebarPanel(
                  fluidRow(
                    actionButton("keyDialog", "Set API key", style='padding:15px 30px; background-color:#93b6c9; font-size:120%; width:100%; color:white'),
                    selectInput("sopilevel", h4("SOPI Level"), choices = unique(hscodeshiny$sopiLevel)),
                    selectInput("sopifilter", h4("Sopi Filter"), choices = NULL, multiple = TRUE, selected = "All SOPI categories"),
                    selectInput("flow", h4("Trade flow"), choices = list("Exports" = "X", "Re-exports" = "RX", "Imports" = "M", "Re-imports" = "RM"), multiple = TRUE),
                    selectInput("country", h4("Country"), choices =  countryshiny[-1], multiple = TRUE),
                    selectInput("partner", h4("Trade partner"), choices =  countryshiny, multiple = TRUE),
                    radioButtons("frequency", h4("Frequency"), choices = list("Monthly" = "M", "Annual" = "A"), inline=TRUE),
                    airDatepickerInput(inputId = "period", label = h4("Period"), multiple = TRUE, clearButton = TRUE, dateFormat = "yyyy MM",maxDate = Sys.Date()),
                    br(),
                    actionButton("sq", "Submit Query", style='padding:15px 30px; font-size:120%; background-color:#007bb8; color:white; width:100%' )
                  )
                ),
                style='width:100%; padding:0px 0px'),

                mainPanel(
                  div(tableOutput("qt"), style = "max-height: 400px; overflow-y: auto; max-width: auto; overflow-x: auto; background-color:white"),
                  downloadButton("download","Download Data")
                )
              )
            )
          )
        )
  # server logic ----
  server <- function(input, output, session) {

    rv <- reactiveValues(key_input = NULL)

    sopilevel <- reactive({
      filter(hscodeshiny, sopiLevel == input$sopilevel)
    })

    observeEvent(sopilevel(), {
      choices <- unique(sopilevel()$sopiFilter)
      updateSelectInput(inputId = "sopifilter", choices = choices)
    })

    sopifilter <- reactive({
      req(input$sopifilter)
      filter(sopilevel(), sopiFilter %in% input$sopifilter)
    })

    observeEvent(input$keyDialog, {
      showModal(
        modalDialog(
          div(textInput("keyInput", "Enter API key"), align = "center", style = "margin-bottom:10px; margin-top:-10px"),
          easyClose = TRUE,
          footer = tagList(
            div(modalButton("Cancel"),actionButton("okButton", "Set"),
                align = "center", style = "margin-bottom:10px; margin-top:-10px")
          )
        )
      )
    })

    observeEvent(input$okButton, {
      key_input <- isolate(input$keyInput)
      print(key_input)
      removeModal()
    })

    observeEvent(input$okButton, {
      key_input <- isolate(input$keyInput)
      rv$key_input <- key_input
    })

    min_view_fmt <- eventReactive(input$frequency, {
      switch(input$frequency,
             "M" = "months",
             "A" = "years")
    })

    observe({
      updateAirDateInput(session = session,
                         inputId =  "period",
                         options = list(view = "years",minView = min_view_fmt()))
    })

    period_input <- reactive({

      if(input$frequency == "M") {
        date_format <- "%Y%m"
      } else if(input$frequency == "A"){
        date_format <- "%Y"
      }
      return(format(as.Date(input$period, origin="1970-01-01"), date_format))
    })

    query_result <- eventReactive(input$sq, {

      hs <- hscodeshiny %>%
        filter(sopiFilter %in% input$sopifilter) %>%
        pull(code) %>%
        unique()

      query_table <- ctApp(freqCode = input$frequency,
                           period = period_input(),
                           reporterCode = input$country,
                           partnerCode = input$partner,
                           flowCode = input$flow,
                           includeDesc = input$description,
                           uncomtrade_key = rv$key_input
      )
      return(query_table)
    })



    output$qt <- renderTable({
      query_result()
    },
    spacing ="xs")

    output$download <- downloadHandler(
      filename = function(){
        "data.csv"
      },
      content = function(file){
        write.csv(query_result(), file, row.names = FALSE)
      }
    )

  }

  # Run app ----
  shinyApp(ui = ui, server = server)
}

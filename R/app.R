#' UN Comtrade shiny app
#'
#' @description run shiny app to query data from the UN Comtrade API.
#' @import shiny shinyWidgets dplyr
#' @importFrom magrittr %>%
#' @export
app <- function(...){

  ui <- div(style="background-color: #73737a !important; overflow-y:visible !important; overflow-x:visible !important; width:100%; height:100%",
            div(titlePanel("comtrader"), style='background-color: #454547; padding:5px 5px; color:white; font-size:120%; text-align:right'),
            div(fluidPage(
              div(sidebarLayout(
                div(sidebarPanel(
                  div(fluidRow(
                    actionButton("keyDialog", "Set API key", style='padding:5px 10px; background-color:#a6c5f7; font-size:120%; width:100%; color:white'),
                    hr(),
                    selectInput("sopilevel", "SOPI Level", choices = unique(hscodeshiny$sopiLevel)),
                    selectInput("sopifilter", "Sopi Filter", choices = NULL, multiple = TRUE, selected = "All SOPI categories"),
                    selectInput("flow", "Trade flow", choices = list("Exports" = "X", "Re-exports" = "RX", "Imports" = "M", "Re-imports" = "RM"), multiple = TRUE),
                    selectInput("country", "Country", choices =  countryshiny[-1], multiple = TRUE),
                    selectInput("partner", "Trade partner", choices =  countryshiny, multiple = TRUE),
                    radioButtons("frequency", "Frequency", choices = list("Monthly" = "M", "Annual" = "A"), inline=TRUE),
                    airDatepickerInput(inputId = "period", label = "Period", multiple = TRUE, clearButton = TRUE, maxDate = Sys.Date()),
                    hr(),
                    actionButton("sq", "Submit Query", style='padding:5px 10px; font-size:120%; background-color:#007bb8; color:white; width:100%'),
                    br(),
                    downloadButton("download","Download Data", style='padding:5px 10px; font-size:120%; background-color:#a6c5f7; color:white; width:100%')
                  ),style='padding:5px 5px'),
                  style='font-size:11px'
                ),
                style='padding:1% 1%'
                ),
                mainPanel(
                  div(tableOutput("qt"), style = "max-height: 60%; width:80%; overflow-y:auto; overflow-x:auto; background-color:white")
                )
              )
            ), style = "overflow-y:visible; overflow-x:visible")
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

    dateFormat_fmt <- eventReactive(input$frequency, {
      switch(input$frequency,
             "M" = "yyyy MM",
             "A" = "yyyy")
    })

    observe({
      updateAirDateInput(session = session,
                         inputId =  "period",
                         options = list(view = "years",minView = min_view_fmt(), dateFormat = dateFormat_fmt()))
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

      sopilevel_quoname <- rlang::quo_name(input$sopilevel)

      hscodes <- omtcodes %>%
        select(NZHSCLevel6,{{sopilevel_quoname}}) %>%
        deframe()

      query_table <- ctApp(freqCode = input$frequency,
                           #
                           cmdCode = hs,
                           #
                           period = period_input(),
                           reporterCode = input$country,
                           partnerCode = input$partner,
                           flowCode = input$flow,
                           #includeDesc = input$description,
                           uncomtrade_key = rv$key_input
      ) #%>%
        #mutate("{sopilevel_quoname}" := dplyr::recode(cmdCode, !!!hscodes))

      return(query_table)
    })



    output$qt <- renderTable({
      query_result()
    },
    #width = "100%",
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

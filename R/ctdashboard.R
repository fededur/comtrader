#' UN Comtrade shiny app
#'
#' @description run shiny app to query data from the UN Comtrade API.
#' @import shiny shinydashboard shinyWidgets dplyr rlang
#' @importFrom magrittr %>%
#' @importFrom purrr pluck
#' @importFrom utils write.csv
#' @export
ctdashboard <- function(){

  hscodes <- comtrader::hscodes
  omtcodes <- comtrader::omtcodes
  reportercodes <- comtrader::reportercodes
  partnercodes <- comtrader::partnercodes

# ui ----
  ui <- dashboardPage(skin = "purple",
                      dashboardHeader(title = "comtrader", tags$li(class = "dropdown",
                                                                   tags$style(".main-header .logo {text-align:left}"))),
                      dashboardSidebar(
                        div(selectInput("sopilevel", "SOPI Level", choices = unique(hscodes$sopiLevel)),
                            selectInput("sopifilter", "Sopi Filter", choices = NULL, multiple = TRUE, selected = "All categories"),
                            selectInput("flow", "Trade flow", choices = list("Exports" = "X", "Re-exports" = "RX", "Imports" = "M", "Re-imports" = "RM"), multiple = TRUE),
                            selectInput("country", "Country", choices =  reportercodes, multiple = TRUE),
                            selectInput("partner", "Trade partner", choices =  partnercodes, multiple = TRUE),
                            radioButtons("frequency", "Frequency", choices = list("Monthly" = "M", "Annual" = "A"), inline=TRUE),
                            airDatepickerInput(inputId = "period", label = "Period", multiple = TRUE, clearButton = TRUE, maxDate = Sys.Date()),
                            style = 'font-weight:normal; font-family:"Calibri"; font-size: 12px;'),
                        hr(),
                        uiOutput("keySide"),
                        div(actionButton("sq", "Submit Query", style='background-color:#007bb8; color:white; text-align:center; width:100%'), style = 'width:200px; align:center')),
                      dashboardBody(
                        tags$head(
                          tags$style(
                            HTML(".textoutput-container {white-space:pre-wrap; max-height:100%; overflow-x:auto; overflow-y:auto; text-overflow: ellipsis;}"))
                          ),
                        tabsetPanel(
                          tabPanel("Data",
                                   br(),
                                   box(
                                     div(tableOutput("qt"), style = 'height:500px; width:100%; overflow-y:visible; overflow-x:auto; padding:10px 10px'),
                                      width = 12,
                                      tags$style(HTML("
                                        #qt td, #qt th {
                                        white-space: nowrap;
                                        overflow: hidden;
                                        text-overflow: ellipsis;
                                        max-width: 150px;
                                        }"))),
                                    downloadButton("download","Download", style='padding:5px 10px; font-size:120%; background-color:#a6c5f7; color:white; width:100%')),
                        tabPanel("Response",
                                 div(class = "textoutput-container",textOutput("message"))
                                 )
                        )
                      )

  )
# server ----
  server <- function(input, output, session) {

    rv <- reactiveValues(key_input = NULL)
    # initial pop up
    pop <- observe({
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

    # store key and remove pop up
    observeEvent(input$okButton, {
      key_input <- isolate(input$keyInput)
      print(key_input)
      removeModal()
    })

    observeEvent(input$okButton, {
      key_input <- isolate(input$keyInput)
      rv$key_input <- key_input
    })

    # render set api button on side panel
    output$keySide <- renderUI({
      if (!is.null(rv$key_input)) {
        return(NULL)
      } else {
        conditionalPanel(
          condition = "is.null(rv$key_input)",
          div(actionButton("keySide", "Set API key",
                           style='background-color:#007bb8;
                                  color:white;
                                  text-align:center;
                                  width:100%'),
              style = 'width:200px; align:center')
        )
      }
    })

    # link actions button to side panel action button
    observeEvent(input$keySide, {
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

    # update selectInput based on filters
    sopilevel <- reactive({
      filter(hscodes, sopiLevel == input$sopilevel)
    })

    observeEvent(sopilevel(), {
      choices <- unique(sopilevel()$sopiFilter)
      updateSelectInput(inputId = "sopifilter", choices = choices)
    })

    sopifilter <- reactive({
      req(input$sopifilter)
      filter(sopilevel(), sopiFilter %in% input$sopifilter)
    })

    output$dataInfo <- renderPrint({
      if(!is.null(rv$key_input)){
        "API key has been set"
      } else {
        "Set API key before submitting your query."
      }
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

      hs <- hscodes %>%
        filter(sopiFilter %in% input$sopifilter) %>%
        pull(code) %>%
        unique()

      sopilevel_quoname <- rlang::quo_name(input$sopilevel)

      hscodes_named <- omtcodes %>%
        select(NZHSCLevel6,{{sopilevel_quoname}}) %>%
        deframe()

      query <- ctApp(freqCode = input$frequency,
                     cmdCode = hs,
                     period = period_input(),
                     reporterCode = input$country,
                     partnerCode = input$partner,
                     flowCode = input$flow,
                     uncomtrade_key = rv$key_input)

      query[["data"]] <- if (nrow(query[["data"]]) != 0 & ncol(query[["data"]]) != 0) {
        query[["data"]] %>%
          mutate("{sopilevel_quoname}" := dplyr::recode(cmdCode, !!!hscodes_named))
      } else {query[["data"]]}

      return(query)
    })


    output$qt <- renderTable({
      query_result() %>%
        purrr::pluck("data")
    })

    output$download <- downloadHandler(
      filename = function(){
        "data.csv"
      },
      content = function(file){
        write.csv(query_result()%>%
                    purrr::pluck("data"), file, row.names = FALSE)
      })

    output$message <- renderText({{query_result()%>%
        purrr::pluck("message")}})
  }

# Run app ----
  shinyApp(ui = ui, server = server)
}

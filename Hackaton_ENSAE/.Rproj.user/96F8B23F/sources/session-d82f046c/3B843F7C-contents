auth_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    user <- reactiveValues(authenticated = FALSE)
    
    observeEvent(input$login, {
      req(input$student_id, input$access_code)
      
      voter <- dbGetQuery(con, 
        "SELECT * FROM voters 
        WHERE student_id = ? AND access_code = ?",
        list(input$student_id, input$access_code)
      )
      
      user$authenticated <- nrow(voter) > 0
    })
    
    return(user)
  })
} 
voting_server <- function(id, user) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Obtenir la liste des postes
    positions <- reactive({
      dbGetQuery(con, "SELECT * FROM positions ORDER BY name")
    })
    
    # Sélecteur de poste
    output$position_selector <- renderUI({
      pos <- positions()
      selectInput(ns("position"), 
                 "Sélectionnez un poste pour voter",
                 choices = setNames(pos$id, pos$name),
                 width = "100%")
    })
    
    # Candidats pour le poste sélectionné
    output$candidates_panel <- renderUI({
      req(input$position)
      
      candidates <- dbGetQuery(con, 
        "SELECT * FROM candidates WHERE position_id = ?",
        params = list(input$position)
      )
      
      if(nrow(candidates) == 0) {
        return(div(class = "alert alert-info",
                  "Aucun candidat n'est encore enregistré pour ce poste"))
      }
      
      position_name <- positions()[positions()$id == input$position, "name"]
      
      tagList(
        h3(sprintf("Candidats pour: %s", position_name)),
        div(class = "candidates-grid",
            lapply(1:nrow(candidates), function(i) {
              candidate_id <- candidates$id[i]
              div(class = "candidate-card",
                  div(class = "candidate-photo",
                      icon("user-circle", class = "fa-4x")
                  ),
                  h4(candidates$name[i]),
                  p(candidates$program[i], class = "program-text"),
                  actionButton(ns(paste0("vote_", candidate_id)),
                              "Voter", class = "btn-vote")
              )
            })
        )
      )
    })
    
    # Observe chaque vote possible
    observe({
      candidates <- dbGetQuery(con, 
        "SELECT id FROM candidates WHERE position_id = ?",
        params = list(input$position)
      )
      
      for(candidate_id in candidates$id) {
        local({
          local_id <- candidate_id
          button_id <- paste0("vote_", local_id)
          
          observeEvent(input[[button_id]], {
            # Vérification des votes antérieurs
            already_voted <- dbGetQuery(con,
              "SELECT COUNT(*) as count FROM votes 
               WHERE voter_id = ? AND position_id = ?",
              params = list(user$id, input$position)
            )$count > 0
            
            if(already_voted) {
              showNotification("Vous avez déjà voté pour ce poste", type = "error")
            } else {
              # Enregistrement du vote
              dbExecute(con,
                "INSERT INTO votes (voter_id, candidate_id, position_id)
                 VALUES (?, ?, ?)",
                params = list(user$id, local_id, input$position)
              )
              
              showNotification("Vote enregistré avec succès", type = "message")
            }
          })
        })
      }
    })
  })
} 
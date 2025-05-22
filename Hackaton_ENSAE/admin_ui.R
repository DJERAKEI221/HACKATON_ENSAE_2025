admin_create_election <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Création d'Élection"),
    textInput(ns("election_name"), "Nom de l'élection"),
    selectInput(ns("election_type"), "Type", 
               choices = c("annuelle", "spéciale")),
    dateRangeInput(ns("election_dates"), "Période de vote"),
    actionButton(ns("create_election"), "Enregistrer", 
                class = "btn-admin")
  )
} 
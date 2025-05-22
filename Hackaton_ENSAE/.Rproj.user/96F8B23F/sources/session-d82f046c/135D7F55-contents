auth_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "auth-panel",
        h3("Authentification Électeur", icon("user-shield")),
        textInput(ns("student_id"), "Numéro étudiant"),
        passwordInput(ns("access_code"), "Code d'accès unique"),
        actionButton(ns("login"), "Vérifier mon éligibilité", 
                     class = "btn-auth"),
        uiOutput(ns("auth_feedback"))
    )
  )
} 
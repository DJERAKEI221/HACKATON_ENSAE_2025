library(shiny)
library(shinyMobile)
library(DBI)
library(RSQLite)

# Connexion à la base de données 
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Récupération des postes pour les onglets
positions <- dbGetQuery(con, "SELECT * FROM positions ORDER BY name")

# Interface mobile avec shinyMobile
ui <- f7Page(
  title = "ENSAE Élections Mobile",
  options = list(theme = "auto"),
  
  f7TabLayout(
    navbar = f7Navbar(
      title = "Élections ENSAE 2024",
      hairline = TRUE,
      shadow = TRUE
    ),
    
    f7Tabs(
      animated = TRUE,
      
      # Onglet Login
      f7Tab(
        tabName = "Login",
        icon = f7Icon("person_crop_circle"),
        active = TRUE,
        
        f7Card(
          f7Input("voterId", "Numéro d'étudiant", placeholder = "Entrez votre identifiant"),
          f7Password("accessCode", "Code d'accès"),
          f7Select("studentYear", "Classe", choices = c("AS1", "AS2", "AS3", "ISEP1", "ISEP2", "ISEP3", "ISE1", "ISE2", "ISE3", "Masters")),
          f7Button("login", "Se connecter", color = "green")
        )
      ),
      
      # Onglet Candidats
      f7Tab(
        tabName = "Candidats",
        icon = f7Icon("person_alt_circle"),
        
        f7Select("mobile_filter_position", "Poste", choices = setNames(positions$id, positions$name)),
        uiOutput("mobile_candidates_profiles")
      ),
      
      # Onglet Vote
      f7Tab(
        tabName = "Vote",
        icon = f7Icon("checkmark_square"),
        
        f7Select("position", "Sélectionnez un poste", choices = setNames(positions$id, positions$name)),
        uiOutput("candidates_mobile")
      ),
      
      # Onglet Résultats
      f7Tab(
        tabName = "Résultats",
        icon = f7Icon("chart_bar"),
        
        f7Select("result_position", "Poste", choices = setNames(positions$id, positions$name)),
        uiOutput("results_mobile"),
        f7Button("downloadPV", "Télécharger PV", color = "blue")
      ),
      
      # Onglet Statistiques
      f7Tab(
        tabName = "Stats",
        icon = f7Icon("graph_square"),
        
        f7Accordion(
          f7AccordionItem(
            title = "Participation globale",
            uiOutput("participation_mobile")
          ),
          f7AccordionItem(
            title = "Par classe",
            uiOutput("yearstats_mobile")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # État utilisateur
  user <- reactiveValues(
    authenticated = FALSE,
    id = NULL
  )
  
  # Authentification
  observeEvent(input$login, {
    # Dans une implémentation réelle, vérifier les identifiants
    user$authenticated <- TRUE
    user$id <- input$voterId
    
    # Notification de connexion
    f7Toast(text = "Connexion réussie", position = "center")
    
    # Naviguer vers l'onglet Vote
    updateF7Tabs(session, id = "tabs", selected = "Vote")
  })
  
  # Affichage des candidats (version mobile)
  output$candidates_mobile <- renderUI({
    req(input$position, user$authenticated)
    
    # Obtenir les candidats
    candidates <- dbGetQuery(con, 
      "SELECT * FROM candidates WHERE position_id = ?",
      params = list(input$position)
    )
    
    if(nrow(candidates) == 0) {
      return(f7Card(
        title = "Information",
        "Aucun candidat pour ce poste"
      ))
    }
    
    # Liste des candidats
    lapply(1:nrow(candidates), function(i) {
      f7Card(
        title = candidates$name[i],
        candidates$program[i],
        footer = f7Button(paste0("vote_", candidates$id[i]), 
                        "Voter", color = "green")
      )
    })
  })
  
  # Affichage des résultats simplifiés pour mobile
  output$results_mobile <- renderUI({
    req(input$result_position)
    
    candidates <- dbGetQuery(con, "SELECT id, name FROM candidates WHERE position_id = ?",
                          params = list(input$result_position))
    
    # Simuler des votes
    set.seed(123)
    votes <- sample(30:100, nrow(candidates), replace = TRUE)
    total <- sum(votes)
    
    # Liste des résultats avec barres de progression
    f7Card(
      title = "Résultats du vote",
      lapply(1:nrow(candidates), function(i) {
        percentage <- round(votes[i]/total*100)
        div(
          p(strong(candidates$name[i]), " - ", votes[i], " votes (", percentage, "%)"),
          f7Progress(percent = percentage, color = "blue")
        )
      })
    )
  })
  
  # Pour les autres sorties mobile...
  output$participation_mobile <- renderUI({
    # Version simplifiée pour mobile
    f7Card(
      title = "Taux de participation: 76%",
      img(src = "participation_chart.png", width = "100%")
    )
  })
  
  # Affichage des profils de candidats pour mobile
  output$mobile_candidates_profiles <- renderUI({
    # Récupérer les candidats selon le filtre de poste
    if(is.null(input$mobile_filter_position)) return(NULL)
    
    candidates <- dbGetQuery(con, 
      "SELECT c.*, p.name as position_name 
       FROM candidates c
       JOIN positions p ON c.position_id = p.id
       WHERE c.position_id = ?
       ORDER BY c.name", 
      params = list(input$mobile_filter_position))
    
    if(nrow(candidates) == 0) {
      return(f7Card(
        title = "Information",
        "Aucun candidat pour ce poste"
      ))
    }
    
    # Liste des profils de candidats
    lapply(1:nrow(candidates), function(i) {
      # Programme par défaut
      program <- if(is.null(candidates$program[i]) || is.na(candidates$program[i]) || candidates$program[i] == "") {
        "Aucun programme disponible."
      } else {
        candidates$program[i]
      }
      
      f7Card(
        title = candidates$name[i],
        f7Accordion(
          f7AccordionItem(
            title = "Programme",
            program
          )
        ),
        footer = if(user$authenticated) {
          f7Button(paste0("mobile_vote_", candidates$id[i]), 
                  "Voter", color = "green")
        }
      )
    })
  })
  
  # Fermer la connexion
  session$onSessionEnded(function() {
    dbDisconnect(con)
  })
}

shinyApp(ui, server) 
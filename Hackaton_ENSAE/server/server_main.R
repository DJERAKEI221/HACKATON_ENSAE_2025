# server/server_main.R - Serveur principal qui assemble tous les modules

function(input, output, session) {
  # Exposer les variables globales pour tous les modules serveur
  positions <- get("positions", envir = .GlobalEnv)
  connection <- get("con", envir = .GlobalEnv)
  
  # État utilisateur partagé entre modules
  user <- reactiveValues(
    id = NULL,
    year = NULL,
    authenticated = FALSE,
    votes = list()
  )
  
  # Variables pour les autres modules serveur
  values <- reactiveValues(
    positions = positions,
    con = connection
  )
  
  # Charger les modules serveur
  source("server/server_auth.R", local = TRUE)
  source("server/server_candidates.R", local = TRUE)
  source("server/server_vote.R", local = TRUE)
  source("server/server_results.R", local = TRUE)
  source("server/server_stats.R", local = TRUE)
  source("server/server_ideas.R", local = TRUE)
  
  # Synchronisation des menus en fonction de l'état d'authentification
  observe({
    # Si l'utilisateur n'est pas authentifié, masquer tous les onglets sauf Accueil
    if (!user$authenticated) {
      # L'onglet Accueil reste toujours visible
      showTab(inputId = "main_navbar", target = "Accueil")
      hideTab(inputId = "main_navbar", target = "Candidats")
      hideTab(inputId = "main_navbar", target = "Vote")
      hideTab(inputId = "main_navbar", target = "Résultats")
      hideTab(inputId = "main_navbar", target = "Statistiques")
      hideTab(inputId = "main_navbar", target = "Boîte à Idées")
    } else {
      # Afficher tous les onglets après authentification
      showTab(inputId = "main_navbar", target = "Accueil")
      showTab(inputId = "main_navbar", target = "Candidats")
      showTab(inputId = "main_navbar", target = "Vote")
      showTab(inputId = "main_navbar", target = "Résultats")
      showTab(inputId = "main_navbar", target = "Statistiques")
      showTab(inputId = "main_navbar", target = "Boîte à Idées")
      
      # Si c'est la première fois que l'utilisateur est authentifié, aller à l'onglet Accueil
      if (is.null(input$main_navbar) || input$main_navbar == "") {
        updateNavbarPage(session, "main_navbar", selected = "Accueil")
      }
    }
  })
  
  # Empêcher la navigation direct si non authentifié
  observeEvent(input$main_navbar, {
    if (!user$authenticated) {
      # L'utilisateur essaie de naviguer sans être authentifié, afficher une notification
      showNotification("Veuillez vous authentifier d'abord", type = "error")
    }
  })
  
  # Fermeture propre de la connexion à la fin de session
  session$onSessionEnded(function() {
    try(dbDisconnect(connection), silent = TRUE)
  })
} 
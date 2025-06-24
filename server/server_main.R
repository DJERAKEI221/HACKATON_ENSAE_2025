# server/server_main.R - Serveur principal qui assemble tous les modules

function(input, output, session) {
  # Exposer les variables globales pour tous les modules serveur
  positions <- get("positions", envir = .GlobalEnv)
  connection <- get("con", envir = .GlobalEnv)
  students_df <- get("students_df", envir = .GlobalEnv) # Access the loaded student data
  
  # État utilisateur partagé entre modules
  user <- reactiveValues(
    id = NULL,
    year = NULL,
    authenticated = FALSE,
    votes = list(),
    name = NULL,
    firstName = NULL,
    full_name = NULL,
    isAdmin = FALSE
  )
  
  # Variables pour les autres modules serveur
  values <- reactiveValues(
    positions = positions,
    con = connection
  )
  
  # Charger le module d'authentification
  source("server/server_auth.R", local = TRUE)
  
  # Initialiser le module d'authentification
  auth_module_output <- auth_server("auth", students_df, user)
  
  # Charger les autres modules serveur
  source("server/server_candidates.R", local = TRUE)
  source("server/server_vote.R", local = TRUE)
  source("server/server_results.R", local = TRUE)
  source("server/server_stats.R", local = TRUE)
  source("server/server_ideas.R", local = TRUE)
  source("server/server_gamification.R", local = TRUE)
  source("server/server_delegates.R", local = TRUE)
  source("server/server_admin.R", local = TRUE)
  
  # Charger le module chatbot
  source("modules/chatbot_module.R", local = TRUE)
  
  # Initialiser le module d'administration
  admin_server("admin", connection, positions)
  
  # Initialiser le module chatbot
  chatbotServer("chatbot")
  
  # Rendre le statut d'administrateur disponible en JavaScript
  observe({
    session$sendCustomMessage("updateAdminStatus", list(isAdmin = user$isAdmin))
  })
  
  # Données réactives pour les votes et résultats
  all_votes <- reactive({
    # Récupérer tous les votes depuis la base de données
    query <- "SELECT * FROM votes"
    votes_data <- dbGetQuery(connection, query)
    return(votes_data)
  })
  
  all_results <- reactive({
    # Récupérer tous les résultats actuels
    results_data <- data.frame()
    
    # Si la table de résultats existe
    if (dbExistsTable(connection, "results")) {
      query <- "SELECT * FROM results"
      results_data <- dbGetQuery(connection, query)
    }
    
    return(results_data)
  })
  
  # Données réactives pour la participation
  participation <- reactive({
    # Utiliser les données CSV pour calculer la participation
    if (is.null(students_df) || nrow(students_df) == 0) {
      warning("CSV student data not loaded or is empty. Cannot calculate participation.")
      return(data.frame(classe = character(), taux = numeric()))
    }
    
    # Calculer le nombre total d'étudiants depuis le CSV
    total_students <- nrow(students_df)
    
    # Calculer le nombre d'étudiants uniques qui ont voté
    voted_students_query <- "SELECT DISTINCT voter_id FROM votes"
    voted_students_df <- dbGetQuery(connection, voted_students_query)
    num_voted <- nrow(voted_students_df)
    
    # Calculer le taux de participation global
    overall_participation <- if (total_students > 0) num_voted / total_students else 0
    
    # Calculer la participation par classe
    participation_by_class <- students_df %>%
      group_by(Classe) %>%
      summarise(
        total = n(),
        voted = sum(Identifiant %in% voted_students_df$voter_id),
        taux = voted / total,
        .groups = 'drop'
      ) %>%
      rename(classe = Classe)
    
    return(participation_by_class)
  })
  
  # Initialiser le module de mises à jour en temps réel
  realtime_updates <- realtimeUpdatesServer(
    "realtime",
    votes_data = all_votes,
    results_data = all_results,
    notification_module = notification_handlers
  )
  
  # Initialiser le module de gamification
  gamification <- gamificationServer("gamification",
    user_data = reactive({
      list(
        id = user$id,
        class = user$year,
        email = user$email
      )
    }),
    vote_data = all_votes,
    participation_data = participation
  )
  
  # Serveur pour la page de profil gamifiée
  gamificationProfileServer("gamification_profile",
    gamification_module = gamification,
    votes_data = all_votes,
    participation_data = participation
  )
  
  # Appeler directement la fonction server_gamification pour l'onglet Participation
  callModule(server_gamification, "participation")
  
  # Observer pour les actions qui donnent des points XP
  observe({
    # Ajouter des XP pour le premier vote de la journée
    if (!is.null(input$submit_vote) && values$vote_success) {
      # Vérifier si c'est le premier vote de la journée
      current_date <- Sys.Date()
      if (is.null(session$userData$last_vote_date) || 
          session$userData$last_vote_date != current_date) {
        session$userData$last_vote_date <- current_date
        # Donner des XP pour le premier vote de la journée
        gamification$addXp(5, "premier_vote_jour")
      }
    }
  })
  
  # Debug de l'état administrateur
  observeEvent(user$isAdmin, {
    cat("Changement de statut admin:", user$isAdmin, "\n")
    cat("Utilisateur authentifié:", user$authenticated, "\n")
    cat("ID utilisateur:", user$id, "\n")
  })
  
  # Empêcher la navigation direct si non authentifié
  observeEvent(input$main_navbar, {
    if (!user$authenticated && input$main_navbar != "Authentification" && input$main_navbar != "Accueil") {
      showNotification("Veuillez vous authentifier d'abord", type = "error")
      updateNavbarPage(session, "main_navbar", selected = "Authentification")
    }
  })
} 
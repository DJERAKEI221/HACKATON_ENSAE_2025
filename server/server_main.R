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
    firstName = NULL
  )
  
  # Variables pour les autres modules serveur
  values <- reactiveValues(
    positions = positions,
    con = connection
  )
  
  # Initialiser le module de notification
  notification_handlers <- notificationServer("notifications")
  
  # Charger le module d'authentification
  source("server/auth_server.R", local = TRUE)
  
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
  
  # Synchronisation des menus en fonction de l'état d'authentification
  observe({
    # Si l'utilisateur n'est pas authentifié, masquer tous les onglets sauf Accueil et Authentification
    if (!user$authenticated) {
      showTab(inputId = "main_navbar", target = "Accueil")
      showTab(inputId = "main_navbar", target = "Authentification")
      hideTab(inputId = "main_navbar", target = "Candidats")
      hideTab(inputId = "main_navbar", target = "Vote")
      hideTab(inputId = "main_navbar", target = "Résultats")
      hideTab(inputId = "main_navbar", target = "Statistiques")
      hideTab(inputId = "main_navbar", target = "Boîte à Idées")
      hideTab(inputId = "main_navbar", target = "Participation")
      hideTab(inputId = "main_navbar", target = "Délégués de Classe")
    } else {
      # Afficher tous les onglets après authentification
      showTab(inputId = "main_navbar", target = "Accueil")
      showTab(inputId = "main_navbar", target = "Candidats")
      showTab(inputId = "main_navbar", target = "Vote")
      showTab(inputId = "main_navbar", target = "Résultats")
      showTab(inputId = "main_navbar", target = "Statistiques")
      showTab(inputId = "main_navbar", target = "Boîte à Idées")
      showTab(inputId = "main_navbar", target = "Participation")
      showTab(inputId = "main_navbar", target = "Délégués de Classe")
      hideTab(inputId = "main_navbar", target = "Authentification")
      
      # Si c'est la première fois que l'utilisateur est authentifié, aller à l'onglet Accueil
      if (is.null(input$main_navbar) || input$main_navbar == "") {
        updateNavbarPage(session, "main_navbar", selected = "Accueil")
      }
      
      # Afficher une notification de bienvenue
      notification_handlers$showImportantNotification(
        "Bienvenue sur l'application électorale",
        paste0("Connecté en tant que ", user$firstName, " ", user$name, " - Classe: ", user$year)
      )
    }
  })
  
  # Empêcher la navigation direct si non authentifié
  observeEvent(input$main_navbar, {
    if (!user$authenticated && input$main_navbar != "Authentification" && input$main_navbar != "Accueil") {
      showNotification("Veuillez vous authentifier d'abord", type = "error")
      updateNavbarPage(session, "main_navbar", selected = "Authentification")
    }
  })
  
  # Notifier les utilisateurs des votes
  observeEvent(input$submit_vote, {
    # Vérifier si le vote a été enregistré avec succès
    if (values$vote_success) {
      notification_handlers$showVoteNotification(
        "Vote enregistré avec succès",
        paste0("Votre vote pour ", input$position, " a été comptabilisé.")
      )
      
      # Ajouter des XP pour le vote
      gamification$addXp(10, "vote")
      gamification$recordActivity("vote", list(position = input$position))
    }
  })
  
  # Notifications pour les mises à jour importantes
  observe({
    # Récupérer le taux de participation actuel
    if (user$authenticated) {
      participation_data <- participation()
      
      if (!is.null(participation_data) && nrow(participation_data) > 0) {
        for (i in 1:nrow(participation_data)) {
          classe <- participation_data$classe[i]
          taux <- participation_data$taux[i]
          
          # Notifications basées sur les seuils de participation
          if (taux >= 0.8) {
            notification_handlers$showParticipationNotification(
              paste0("Excellente participation pour ", classe),
              paste0("Taux de participation: ", round(taux * 100, 1), "%")
            )
          }
        }
      }
    }
  })
  
  # Fermeture propre de la connexion à la fin de session
  session$onSessionEnded(function() {
    try(dbDisconnect(connection), silent = TRUE)
  })
} 
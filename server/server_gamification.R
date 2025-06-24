# Serveur pour la gestion de la gamification et participation

# Fonction pour générer les badges des utilisateurs
renderBadges <- function(badges_data) {
  badges <- lapply(1:length(badges_data), function(i) {
    badge <- badges_data[[i]]
    
    # Choix de l'icône selon le badge
    badge_icon <- switch(
      toupper(gsub(".png$", "", basename(badge$icon))),
      "VOTE" = icon("vote-yea"),
      "COMPLETE" = icon("check-circle"),
      "TROPHY" = icon("trophy"),
      "STATS" = icon("chart-line"),
      icon("award") # défaut
    )
    
    div(class = "badge-card",
      div(class = "badge-icon earned", badge_icon),
      h4(class = "badge-name", badge$name),
      p(class = "badge-description", badge$description)
    )
  })
  
  # Retourner un seul élément contenant tous les badges
  return(div(badges))
}

# Fonction pour générer les statistiques
renderStats <- function(stats_data) {
  stats <- lapply(1:length(stats_data), function(i) {
    stat <- stats_data[[i]]
    
    div(class = "stat-card",
      div(class = "stat-circle", stat$value),
      div(class = "stat-info",
        h4(class = "stat-name", stat$name),
        p(class = "stat-value", stat$description),
        if(!is.null(stat$progress)) {
          div(class = "progress",
            div(class = "progress-bar", role = "progressbar", 
                style = paste0("width: ", stat$progress, "%;"))
          )
        }
      )
    )
  })
  
  return(stats)
}

# Fonction pour générer les rangs du leaderboard
renderLeaderboard <- function(leaderboard_data) {
  # Vérifier si des données sont disponibles
  if (is.null(leaderboard_data) || length(leaderboard_data) == 0) {
    cat("Aucune donnée de classement disponible\n")
    return(div(class = "leaderboard-empty",
      div(class = "text-center p-4",
        icon("vote-yea", class = "mb-3", style = "font-size: 3rem; color: #6c757d;"),
        h5("Aucun vote enregistré pour le moment", class = "text-muted"),
        p("Le classement affichera les votants au fur et à mesure des votes.", class = "text-muted")
      )
    ))
  }
  
  cat("Rendu du classement avec", length(leaderboard_data), "entrées\n")
  
  leaderboard_entries <- lapply(1:length(leaderboard_data), function(i) {
    entry <- leaderboard_data[[i]]
    position_class <- ""
    
    # Ajouter des classes spéciales pour les 3 premiers
    if (i == 1) {
      position_class <- "top-1"
    } else if (i == 2) {
      position_class <- "top-2"
    } else if (i == 3) {
      position_class <- "top-3"
    }
    
    # Sécuriser les valeurs pour éviter les erreurs
    name <- if(is.null(entry$name)) "Inconnu" else entry$name
    classe <- if(is.null(entry$classe)) "Non définie" else entry$classe
    aes_votes <- if(is.null(entry$aes_votes)) 0 else entry$aes_votes
    delegate_votes <- if(is.null(entry$delegate_votes)) 0 else entry$delegate_votes
    total_votes <- if(is.null(entry$total_votes)) 0 else entry$total_votes
    score <- if(is.null(entry$score)) 0 else entry$score
    
    # Logs pour débogage
    cat("Entrée #", i, ":", name, "/", classe, "- Votes AES:", aes_votes, "- Votes délégués:", delegate_votes, "- Total:", total_votes, "- Score:", score, "\n")
    
    div(class = "leaderboard-row",
      # Position au classement
      div(class = paste("leaderboard-position", position_class), i),
      
      # Informations sur le votant
      div(class = "leaderboard-voter-info",
        div(class = "leaderboard-name", name),
        div(class = "leaderboard-class", classe)
      ),
      
      # Détail des votes
      div(class = "leaderboard-votes-detail",
        div(class = "vote-count aes-votes", 
          span(class = "vote-label", "AES: "), 
          span(class = "vote-value", aes_votes)
        ),
        div(class = "vote-count delegate-votes", 
          span(class = "vote-label", "Délégués: "), 
          span(class = "vote-value", delegate_votes)
        )
      ),
      
      # Score total
      div(class = "leaderboard-score", 
        div(class = "total-votes",
          span(class = "vote-total-label", "Total: "), 
          span(class = "vote-total-value", total_votes)
        ),
        div(class = "score-points",
          span(class = "score-value", score), 
          span(class = "score-label", " pts")
        )
      )
    )
  })
  
  # Si pour une raison quelconque le lapply a échoué, afficher un message
  if (length(leaderboard_entries) == 0) {
    cat("Erreur: Aucune entrée générée après le traitement\n")
    return(div(class = "leaderboard-empty",
      div(class = "text-center p-4",
        icon("exclamation-triangle", class = "mb-3", style = "font-size: 3rem; color: #dc3545;"),
        h5("Erreur lors de la génération du classement", class = "text-danger"),
        p("Une erreur est survenue lors du traitement des données de vote.", class = "text-muted")
      )
    ))
  }
  
  cat("Classement rendu avec succès\n")
  return(div(leaderboard_entries))
}

# Logique serveur pour la gamification
server_gamification <- function(input, output, session) {
  # Namespace pour les output
  ns <- session$ns
  
  # Output de test simple pour vérifier si les rendus fonctionnent
  output$test_output <- renderText({
    "Test de rendu - si ce texte est visible, le rendu UI fonctionne"
  })
  
  output[["participation-test_output"]] <- renderText({
    "Test de rendu avec namespace - si ce texte est visible, le rendu UI avec namespace fonctionne"
  })
  
  # Initialiser le compteur de votes s'il n'existe pas encore
  observe({
    if (is.null(values$votes)) {
      values$votes <- 0
      cat("Initialisation du compteur de votes\n")
    }
  })
  
  # Vérifier la connexion à la base de données et les tables existantes
  observe({
    if (!is.null(values$con)) {
      tryCatch({
        tables <- dbListTables(values$con)
        cat("Tables disponibles dans la base de données:", paste(tables, collapse=", "), "\n")
        
        # Compter le nombre d'entrées dans les tables de votes
        if ("votes" %in% tables) {
          vote_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM votes")$count
          cat("Nombre de votes AES dans la base:", vote_count, "\n")
        }
        
        if ("delegate_votes" %in% tables) {
          delegate_vote_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM delegate_votes")$count
          cat("Nombre de votes délégués dans la base:", delegate_vote_count, "\n")
        }
      }, error = function(e) {
        cat("Erreur lors de la vérification de la base de données:", e$message, "\n")
      })
    } else {
      cat("Aucune connexion à la base de données disponible\n")
    }
  })
  
  # Données statiques pour les badges et statistiques (à remplacer par des données réelles)
  badges_data <- list(
    list(
      name = "Premier Vote",
      description = "A voté pour la première fois",
      icon = "vote.png"
    ),
    list(
      name = "Votant Complet",
      description = "A voté pour tous les postes",
      icon = "complete.png"
    ),
    list(
      name = "Votant Matinal",
      description = "A voté dans les premières heures",
      icon = "morning.png"
    ),
    list(
      name = "Statisticien",
      description = "A consulté les statistiques",
      icon = "stats.png"
    )
  )
  
  stats_data <- list(
    list(
      name = "Votes effectués",
      value = "3",
      description = "Sur 5 votes possibles",
      progress = 60
    ),
    list(
      name = "Pages visitées",
      value = "7",
      description = "Sur 8 pages disponibles",
      progress = 87.5
    ),
    list(
      name = "Actions totales",
      value = "12",
      description = "Ensemble des interactions avec l'application",
      progress = NULL
    )
  )
  
  # Fonction pour générer le leaderboard avec les vrais noms des élèves
  generate_leaderboard <- function() {
    # Débogage
    cat("Génération du classement des votants...\n")
    
    # Vérifier si les données CSV sont disponibles
    if (is.null(students_df) || nrow(students_df) == 0) {
      cat("Erreur: Données étudiants manquantes\n")
      return(list())
    }
    
    # Récupérer les votes AES depuis la base de données
    aes_votes_query <- "SELECT voter_id, COUNT(*) as vote_count FROM votes GROUP BY voter_id"
    aes_votes_data <- tryCatch({
      results <- dbGetQuery(values$con, aes_votes_query)
      cat("Votes AES trouvés:", nrow(results), "\n")
      results
    }, error = function(e) {
      cat("Erreur lors de la récupération des votes AES:", e$message, "\n")
      data.frame(voter_id = character(), vote_count = integer())
    })
    
    # Récupérer les votes délégués depuis la base de données
    delegate_votes_query <- "SELECT voter_id, COUNT(*) as vote_count FROM delegate_votes GROUP BY voter_id"
    delegate_votes_data <- tryCatch({
      results <- dbGetQuery(values$con, delegate_votes_query)
      cat("Votes délégués trouvés:", nrow(results), "\n")
      results
    }, error = function(e) {
      cat("Erreur lors de la récupération des votes délégués:", e$message, "\n")
      data.frame(voter_id = character(), vote_count = integer())
    })
    
    # Vérifier si nous avons des votes
    if (nrow(aes_votes_data) == 0 && nrow(delegate_votes_data) == 0) {
      cat("Aucun vote trouvé, renvoie une liste vide\n")
      return(list())
    }
    
    # Combiner les données de votes en un seul dataframe
    all_voter_ids <- unique(c(aes_votes_data$voter_id, delegate_votes_data$voter_id))
    cat("Nombre total de votants uniques:", length(all_voter_ids), "\n")
    
    # Créer un leaderboard basé uniquement sur les étudiants qui ont réellement voté
    leaderboard_list <- list()
    
    for (voter_id in all_voter_ids) {
      # Obtenir le nombre de votes AES
      aes_count <- 0
      if (voter_id %in% aes_votes_data$voter_id) {
        aes_count <- aes_votes_data$vote_count[aes_votes_data$voter_id == voter_id]
      }
      
      # Obtenir le nombre de votes délégués
      delegate_count <- 0
      if (voter_id %in% delegate_votes_data$voter_id) {
        delegate_count <- delegate_votes_data$vote_count[delegate_votes_data$voter_id == voter_id]
      }
      
      # Calculer le total des votes
      total_votes <- aes_count + delegate_count
      
      # Obtenir les informations de l'étudiant et son nom complet
      full_name <- get_full_name(voter_id)
      
      # Obtenir la classe de l'étudiant
      student_info <- students_df[students_df$Identifiant == voter_id, ]
      student_class <- if(nrow(student_info) > 0 && !is.null(student_info$Classe[1])) student_info$Classe[1] else "Non définie"
      
      # Score basé sur le nombre total de votes (100 points par vote)
      score <- total_votes * 100
      
      cat("Votant trouvé:", full_name, "- Votes AES:", aes_count, "- Votes délégués:", delegate_count, "- Total:", total_votes, "\n")
      
      # Inclure le détail des votes dans l'entrée
      leaderboard_list[[length(leaderboard_list) + 1]] <- list(
        name = full_name,
        score = score,
        classe = student_class,
        aes_votes = aes_count,
        delegate_votes = delegate_count,
        total_votes = total_votes
      )
    }
    
    # Si aucun vote n'a encore été enregistré, renvoyer une liste vide
    if (length(leaderboard_list) == 0) {
      cat("Aucun votant valide trouvé, renvoie une liste vide\n")
      return(list())
    }
    
    # Trier par score décroissant
    leaderboard_list <- leaderboard_list[order(sapply(leaderboard_list, function(x) x$score), decreasing = TRUE)]
    cat("Classement généré avec", length(leaderboard_list), "entrées\n")
    
    return(leaderboard_list)
  }
  
  # Données du niveau
  user_level_data <- reactiveVal(list(
    level = 0,
    name = "Débutant",
    current_xp = 0,
    next_level_xp = 10
  ))
  
  # Render les badges
  output[["badges_container"]] <- renderUI({
    renderBadges(badges_data)
  })
  
  # Aussi avec le bon namespace
  output[["participation-badges_container"]] <- renderUI({
    renderBadges(badges_data)
  })
  
  # Render les statistiques
  output[["stats_container"]] <- renderUI({
    renderStats(stats_data)
  })
  
  # Aussi avec le bon namespace
  output[["participation-stats_container"]] <- renderUI({
    renderStats(stats_data)
  })
  
  # Données réactives du leaderboard
  leaderboard_reactive <- reactive({
    # Invalider quand il y a de nouveaux votes
    values$votes
    # Invalider toutes les 30 secondes pour actualiser le classement
    invalidateLater(30000)
    # Prendre en compte le déclencheur JavaScript
    input$refresh_leaderboard_trigger
    
    cat("DÉBOGAGE: Exécution de leaderboard_reactive()\n")
    # Générer et retourner le classement
    result <- generate_leaderboard()
    cat("DÉBOGAGE: Classement généré avec", length(result), "entrées\n")
    return(result)
  })
  
  # Observer pour réagir au déclencheur de rafraîchissement JavaScript
  observeEvent(input$refresh_leaderboard_trigger, {
    cat("Déclencheur de rafraîchissement JavaScript activé\n")
    # Forcer l'invalidation du cache
    invalidateLater(10)
  })
  
  # Render le leaderboard avec les vrais noms des élèves
  output[["participation-leaderboard_container"]] <- renderUI({
    cat("DÉBOGAGE: Début de renderUI pour le classement\n")
    leaderboard_data <- leaderboard_reactive()
    cat("DÉBOGAGE: Données du classement récupérées, génération du HTML\n")
    result <- renderLeaderboard(leaderboard_data)
    cat("DÉBOGAGE: HTML du classement généré\n")
    return(result)
  })
  
  # Forcer une mise à jour initiale du classement
  observe({
    # Cette observation s'exécute une seule fois au chargement de la page
    cat("Forçage de la mise à jour initiale du classement\n")
    # Incrémenter le compteur pour forcer le rafraîchissement
    isolate({
      values$votes <- values$votes + 1
    })
  })
  
  # Render le niveau de l'utilisateur
  output[["user_level"]] <- renderText({
    user_level_data()$level
  })
  
  # Aussi avec le bon namespace
  output[["participation-user_level"]] <- renderText({
    user_level_data()$level
  })
  
  output[["level_name"]] <- renderText({
    user_level_data()$name
  })
  
  # Aussi avec le bon namespace
  output[["participation-level_name"]] <- renderText({
    user_level_data()$name
  })
  
  output[["xp_current"]] <- renderText({
    user_level_data()$current_xp
  })
  
  # Aussi avec le bon namespace
  output[["participation-xp_current"]] <- renderText({
    user_level_data()$current_xp
  })
  
  output[["xp_next"]] <- renderText({
    user_level_data()$next_level_xp
  })
  
  # Aussi avec le bon namespace
  output[["participation-xp_next"]] <- renderText({
    user_level_data()$next_level_xp
  })
  
  # Mettre à jour la barre de progression d'XP
  observe({
    level_data <- user_level_data()
    progress_percent <- (level_data$current_xp / level_data$next_level_xp) * 100
    
    session$sendCustomMessage(type = "update-xp-progress", 
                           message = list(percent = progress_percent))
  })
} 
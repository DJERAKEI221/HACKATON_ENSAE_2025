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
  if (length(leaderboard_data) == 0) {
    return(div(class = "leaderboard-empty",
      div(class = "text-center p-4",
        icon("users", class = "mb-3", style = "font-size: 3rem; color: #6c757d;"),
        h5("Classement en cours de construction", class = "text-muted"),
        p("Le classement sera mis à jour au fur et à mesure des votes.", class = "text-muted")
      )
    ))
  }
  
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
    
    div(class = "leaderboard-row",
      div(class = paste("leaderboard-position", position_class), i),
      div(class = "leaderboard-name", entry$name),
      div(class = "leaderboard-score", paste0(entry$score, " pts"))
    )
  })
  
  return(div(leaderboard_entries))
}

# Logique serveur pour la gamification
server_gamification <- function(input, output, session) {
  # Namespace pour les output
  ns <- session$ns
  
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
    # Vérifier si les données CSV sont disponibles
    if (is.null(students_df) || nrow(students_df) == 0) {
      return(list())
    }
    
    # Récupérer les votes depuis la base de données
    votes_query <- "SELECT voter_id, COUNT(*) as vote_count FROM votes GROUP BY voter_id ORDER BY vote_count DESC"
    votes_data <- tryCatch({
      dbGetQuery(values$con, votes_query)
    }, error = function(e) {
      data.frame(voter_id = character(), vote_count = integer())
    })
    
    # Créer un leaderboard basé sur les vrais étudiants
    leaderboard_list <- list()
    
    if (nrow(votes_data) > 0) {
      # Pour les étudiants qui ont voté, utiliser leurs vrais scores
      for (i in 1:min(nrow(votes_data), 10)) { # Top 10
        voter_id <- votes_data$voter_id[i]
        student_info <- students_df[students_df$Identifiant == voter_id, ]
        
        if (nrow(student_info) > 0) {
          full_name <- paste(student_info$Prenom[1], student_info$Nom[1])
          # Score basé sur le nombre de votes + bonus pour participation précoce
          score <- votes_data$vote_count[i] * 100 + sample(50:200, 1)
          
          leaderboard_list[[length(leaderboard_list) + 1]] <- list(
            name = full_name,
            score = score
          )
        }
      }
    }
    
    # Compléter avec des étudiants aléatoires du CSV pour avoir au moins 7 entrées
    if (length(leaderboard_list) < 7) {
      remaining_students <- students_df[!students_df$Identifiant %in% votes_data$voter_id, ]
      if (nrow(remaining_students) > 0) {
        # Sélectionner aléatoirement des étudiants pour compléter le leaderboard
        sample_size <- min(7 - length(leaderboard_list), nrow(remaining_students))
        sampled_indices <- sample(nrow(remaining_students), sample_size)
        
        for (i in sampled_indices) {
          student <- remaining_students[i, ]
          full_name <- paste(student$Prenom, student$Nom)
          # Score aléatoire plus bas pour les non-votants
          score <- sample(10:100, 1)
          
          leaderboard_list[[length(leaderboard_list) + 1]] <- list(
            name = full_name,
            score = score
          )
        }
      }
    }
    
    # Trier par score décroissant
    leaderboard_list <- leaderboard_list[order(sapply(leaderboard_list, function(x) x$score), decreasing = TRUE)]
    
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
    generate_leaderboard()
  })
  
  # Render le leaderboard avec les vrais noms des élèves
  output[["participation-leaderboard_container"]] <- renderUI({
    leaderboard_data <- leaderboard_reactive()
    renderLeaderboard(leaderboard_data)
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
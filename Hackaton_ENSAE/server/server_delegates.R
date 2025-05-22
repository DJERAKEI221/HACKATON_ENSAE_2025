# server/server_delegates.R - Gestion des élections des délégués de classe

# Créer les tables nécessaires pour les délégués dans un contexte réactif
observe({
  req(values$con)
  
  # Table des candidats délégués
  dbExecute(values$con, "
    CREATE TABLE IF NOT EXISTS delegate_candidates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      class TEXT NOT NULL,
      name TEXT NOT NULL,
      type TEXT NOT NULL, -- 'main' pour délégué principal, 'deputy' pour adjoint
      bio TEXT,
      UNIQUE(class, name, type)
    )")
  
  # Table des votes pour les délégués
  dbExecute(values$con, "
    CREATE TABLE IF NOT EXISTS delegate_votes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      voter_id INTEGER NOT NULL,
      candidate_id INTEGER NOT NULL,
      class TEXT NOT NULL,
      type TEXT NOT NULL, -- 'main' pour délégué principal, 'deputy' pour adjoint
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(candidate_id) REFERENCES delegate_candidates(id)
    )")
  
  # Insérer des données de test si la table est vide
  count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM delegate_candidates")
  
  if (count$count == 0) {
    # Liste des classes
    classes <- c("as1", "as2", "as3", "isep1", "isep2", "isep3", "ise1", "ise2", "ise3", "masters")
    
    # Pour chaque classe, ajouter des candidats pour délégué principal et adjoint
    for (class in classes) {
      # Candidats pour délégué principal
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Candidat 1 - ", toupper(class)), "main", 
                              "Étudiant motivé et engagé pour représenter sa classe."))
      
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Candidat 2 - ", toupper(class)), "main", 
                              "Promet de faire le lien entre les étudiants et l'administration."))
      
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Candidat 3 - ", toupper(class)), "main", 
                              "Se présente pour améliorer les conditions d'études et l'environnement de classe."))
      
      # Candidats pour délégué adjoint
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Adjoint 1 - ", toupper(class)), "deputy", 
                              "Souhaite soutenir efficacement le délégué principal et travailler en équipe."))
      
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Adjoint 2 - ", toupper(class)), "deputy", 
                              "Veut assurer la continuité et la communication au sein de la classe."))
      
      dbExecute(values$con, 
                "INSERT INTO delegate_candidates (class, name, type, bio) VALUES (?, ?, ?, ?)",
                params = list(class, paste0("Adjoint 3 - ", toupper(class)), "deputy", 
                              "S'engage à être à l'écoute des étudiants et à relayer leurs préoccupations."))
    }
  }
})

# Affichage des choix pour le délégué principal
output$main_delegate_choices <- renderUI({
  req(input$delegate_class)
  
  # Récupérer les candidats pour cette classe et type
  candidates <- dbGetQuery(values$con, 
    "SELECT id, name, bio FROM delegate_candidates 
     WHERE class = ? AND type = 'main' ORDER BY name",
    params = list(input$delegate_class)
  )
  
  if (nrow(candidates) == 0) {
    return(div(class = "alert alert-info", "Aucun candidat disponible pour cette classe."))
  }
  
  # Créer les options radio
  radioButtons("main_delegate_choice", "Choisissez un délégué principal:",
               choiceNames = lapply(1:nrow(candidates), function(i) {
                 div(
                   strong(candidates$name[i]),
                   tags$br(),
                   span(class = "text-muted", candidates$bio[i])
                 )
               }),
               choiceValues = candidates$id,
               selected = character(0)
  )
})

# Affichage des choix pour le délégué adjoint
output$deputy_delegate_choices <- renderUI({
  req(input$delegate_class)
  
  # Récupérer les candidats pour cette classe et type
  candidates <- dbGetQuery(values$con, 
    "SELECT id, name, bio FROM delegate_candidates 
     WHERE class = ? AND type = 'deputy' ORDER BY name",
    params = list(input$delegate_class)
  )
  
  if (nrow(candidates) == 0) {
    return(div(class = "alert alert-info", "Aucun candidat disponible pour cette classe."))
  }
  
  # Créer les options radio
  radioButtons("deputy_delegate_choice", "Choisissez un délégué adjoint:",
               choiceNames = lapply(1:nrow(candidates), function(i) {
                 div(
                   strong(candidates$name[i]),
                   tags$br(),
                   span(class = "text-muted", candidates$bio[i])
                 )
               }),
               choiceValues = candidates$id,
               selected = character(0)
  )
})

# Traitement du vote pour les délégués
observeEvent(input$submit_delegate_vote, {
  # Vérifier que l'utilisateur est authentifié
  req(user$authenticated, user$id)
  
  # Vérifier qu'un choix a été fait pour au moins un type de délégué
  if (is.null(input$main_delegate_choice) && is.null(input$deputy_delegate_choice)) {
    showNotification("Veuillez choisir au moins un délégué pour voter.", type = "warning")
    return()
  }
  
  # Vérifier si l'utilisateur a déjà voté pour cette classe
  has_voted_main <- FALSE
  has_voted_deputy <- FALSE
  
  if (!is.null(input$main_delegate_choice)) {
    existing_vote_main <- dbGetQuery(values$con, 
      "SELECT id FROM delegate_votes 
       WHERE voter_id = ? AND class = ? AND type = 'main'",
      params = list(user$id, input$delegate_class)
    )
    has_voted_main <- nrow(existing_vote_main) > 0
  }
  
  if (!is.null(input$deputy_delegate_choice)) {
    existing_vote_deputy <- dbGetQuery(values$con, 
      "SELECT id FROM delegate_votes 
       WHERE voter_id = ? AND class = ? AND type = 'deputy'",
      params = list(user$id, input$delegate_class)
    )
    has_voted_deputy <- nrow(existing_vote_deputy) > 0
  }
  
  # Si l'utilisateur a déjà voté, afficher un message
  if (has_voted_main && has_voted_deputy) {
    showNotification("Vous avez déjà voté pour les délégués de cette classe.", type = "warning")
    return()
  }
  
  # Enregistrer les votes
  tryCatch({
    # Vote pour le délégué principal
    if (!is.null(input$main_delegate_choice) && !has_voted_main) {
      dbExecute(values$con, 
        "INSERT INTO delegate_votes (voter_id, candidate_id, class, type) VALUES (?, ?, ?, 'main')",
        params = list(user$id, input$main_delegate_choice, input$delegate_class)
      )
    }
    
    # Vote pour le délégué adjoint
    if (!is.null(input$deputy_delegate_choice) && !has_voted_deputy) {
      dbExecute(values$con, 
        "INSERT INTO delegate_votes (voter_id, candidate_id, class, type) VALUES (?, ?, ?, 'deputy')",
        params = list(user$id, input$deputy_delegate_choice, input$delegate_class)
      )
    }
    
    # Notification de succès
    showNotification("Votre vote a été enregistré avec succès!", type = "message")
    
    # Réinitialiser les sélections
    updateRadioButtons(session, "main_delegate_choice", selected = character(0))
    updateRadioButtons(session, "deputy_delegate_choice", selected = character(0))
    
  }, error = function(e) {
    showNotification(paste("Erreur lors de l'enregistrement du vote:", e$message), type = "error")
  })
})

# Résultats pour le délégué principal
output$main_delegate_results <- renderPlot({
  req(input$delegate_results_class)
  
  # Récupérer les résultats
  results <- dbGetQuery(values$con, 
    "SELECT c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.class = ? AND c.type = 'main'
     GROUP BY c.id
     ORDER BY votes DESC",
    params = list(input$delegate_results_class)
  )
  
  if (nrow(results) == 0) {
    return(NULL)
  }
  
  # Créer le graphique
  ggplot(results, aes(x = reorder(name, -votes), y = votes, fill = name)) +
    geom_col() +
    geom_text(aes(label = votes), vjust = -0.5) +
    scale_fill_brewer(palette = "Blues") +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(x = NULL, y = "Nombre de votes")
})

# Résultats pour le délégué adjoint
output$deputy_delegate_results <- renderPlot({
  req(input$delegate_results_class)
  
  # Récupérer les résultats
  results <- dbGetQuery(values$con, 
    "SELECT c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.class = ? AND c.type = 'deputy'
     GROUP BY c.id
     ORDER BY votes DESC",
    params = list(input$delegate_results_class)
  )
  
  if (nrow(results) == 0) {
    return(NULL)
  }
  
  # Créer le graphique
  ggplot(results, aes(x = reorder(name, -votes), y = votes, fill = name)) +
    geom_col() +
    geom_text(aes(label = votes), vjust = -0.5) +
    scale_fill_brewer(palette = "Greens") +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(x = NULL, y = "Nombre de votes")
})

# Tableau des résultats détaillés
output$delegate_votes_table <- renderTable({
  req(input$delegate_results_class)
  
  # Récupérer les résultats combinés
  results <- dbGetQuery(values$con, 
    "SELECT c.type, c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.class = ?
     GROUP BY c.id
     ORDER BY c.type, votes DESC",
    params = list(input$delegate_results_class)
  )
  
  if (nrow(results) == 0) {
    return(data.frame(Type = character(), Candidat = character(), Votes = integer()))
  }
  
  # Formater les types
  results$type <- ifelse(results$type == "main", "Délégué Principal", "Délégué Adjoint")
  
  # Renommer les colonnes
  names(results) <- c("Type", "Candidat", "Votes")
  
  results
}) 
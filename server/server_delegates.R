# server/server_delegates.R - Gestion des élections des délégués de classe

# Variable réactive pour stocker la classe sélectionnée (unifiée pour vote et résultats)
selected_class <- reactiveVal(NULL)

# Variable réactive pour forcer la mise à jour des candidats
refresh_candidates <- reactiveVal(0)

# Observer pour définir automatiquement la classe de l'étudiant authentifié
observe({
  # Si l'utilisateur est authentifié, utiliser sa classe automatiquement
  if (!is.null(user$authenticated) && user$authenticated && !is.null(user$year)) {
    if (is.null(selected_class()) || selected_class() != user$year) {
      selected_class(user$year)
      refresh_candidates(refresh_candidates() + 1)
      showNotification(paste("Classe automatiquement définie:", user$year), type = "message")
    }
  }
})

# Gestion des boutons de sélection de classe pour les RÉSULTATS SEULEMENT
# (Le vote utilise maintenant automatiquement la classe de l'étudiant authentifié)
observeEvent(input$results_as1, { 
  selected_class("AS1")
  showNotification("Résultats AS1 affichés", type = "message")
})
observeEvent(input$results_as2, { 
  selected_class("AS2")
  showNotification("Résultats AS2 affichés", type = "message")
})
observeEvent(input$results_as3, { 
  selected_class("AS3")
  showNotification("Résultats AS3 affichés", type = "message")
})
observeEvent(input$results_isep1, { 
  selected_class("ISEP1")
  showNotification("Résultats ISEP1 affichés", type = "message")
})
observeEvent(input$results_isep2, { 
  selected_class("ISEP2")
  showNotification("Résultats ISEP2 affichés", type = "message")
})
observeEvent(input$results_isep3, { 
  selected_class("ISEP3")
  showNotification("Résultats ISEP3 affichés", type = "message")
})
observeEvent(input$results_ise1_maths, { 
  selected_class("ISE1 Maths")
  showNotification("Résultats ISE1 Maths affichés", type = "message")
})
observeEvent(input$results_ise1_eco, { 
  selected_class("ISE1 Eco")
  showNotification("Résultats ISE1 Eco affichés", type = "message")
})
observeEvent(input$results_ise2, { 
  selected_class("ISE2")
  showNotification("Résultats ISE2 affichés", type = "message")
})
observeEvent(input$results_ise3, { 
  selected_class("ISE3")
  showNotification("Résultats ISE3 affichés", type = "message")
})
observeEvent(input$results_masters, { 
  selected_class("Masters")
  showNotification("Résultats Masters affichés", type = "message")
})



# Affichage de la classe de l'étudiant authentifié
output$selected_class_display <- renderUI({
  if (!is.null(user$authenticated) && user$authenticated && !is.null(user$year)) {
    div(class = "alert alert-success mt-3",
        icon("user-graduate", class = "me-2"),
        strong("Votre classe : "), user$year,
        br(),
        em("Vous pouvez voter uniquement pour les délégués de votre classe.")
    )
  } else {
    div(class = "alert alert-warning mt-3",
        icon("exclamation-triangle", class = "me-2"),
        strong("Veuillez vous authentifier pour voter.")
    )
  }
})

# Affichage de la classe sélectionnée pour les résultats (utilise la même variable que le vote)
output$selected_results_class_display <- renderUI({
  if (!is.null(selected_class())) {
    div(class = "alert alert-info py-2 px-3",
        icon("chart-bar", class = "me-2"),
        strong("Résultats pour : "), selected_class()
    )
  }
})

# Affichage des choix pour le délégué principal
output$main_delegate_choices <- renderUI({
  # Dépendre de la classe sélectionnée ET du trigger de rafraîchissement
  req(selected_class())
  refresh_candidates() # Déclenche le rendu quand cette valeur change
  
  # Message de débogage
  showNotification(paste("Recherche candidats délégués pour:", selected_class()), type = "message")
  
  # Récupérer les candidats pour cette classe et type
  candidates <- dbGetQuery(values$con, 
    "SELECT id, name, bio, program FROM delegate_candidates 
     WHERE classe = ? AND position_type = 'delegue' ORDER BY name",
    params = list(selected_class())
  )
  
  # Message de débogage pour le nombre de candidats trouvés
  showNotification(paste("Candidats délégués trouvés:", nrow(candidates)), type = "message")
  
  if (nrow(candidates) == 0) {
    return(div(class = "alert alert-warning text-center", 
               style = "margin: 20px; padding: 20px;",
               icon("exclamation-triangle", class = "me-2"),
               h4("Aucun candidat délégué disponible"),
               p(paste("Aucun candidat délégué trouvé pour la classe", selected_class()))
    ))
  }
  
  # Affichage très visible et forcé
  div(
    # Titre très visible
    div(style = "background: linear-gradient(135deg, #007bff, #0056b3); color: white; padding: 15px; border-radius: 8px; margin-bottom: 15px; text-align: center;",
      h3("CANDIDATS DÉLÉGUÉS PRINCIPAUX", style = "margin: 0; font-weight: bold;"),
      h4(paste("Classe:", selected_class()), style = "margin: 5px 0 0 0; color: #fff3cd;")
    ),
    
    # Liste des candidats avec style très visible
    div(style = "background-color: #f8f9fa; padding: 15px; border-radius: 8px;",
      lapply(1:nrow(candidates), function(i) {
        div(class = "candidate-item", 
            style = "background-color: white; border: 2px solid #007bff; border-radius: 8px; padding: 12px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          div(class = "form-check",
            tags$input(type = "radio", 
                      class = "form-check-input", 
                      name = "main_delegate_choice", 
                      id = paste0("main_", candidates$id[i]),
                      value = candidates$id[i],
                      style = "width: 20px; height: 20px; margin-right: 10px;"),
            tags$label(class = "form-check-label w-100", 
                      `for` = paste0("main_", candidates$id[i]),
                      style = "cursor: pointer;",
              div(
                h4(candidates$name[i], style = "color: #007bff; margin-bottom: 0; font-weight: bold;")
              )
            )
          )
        )
      })
    )
  )
})

# Affichage des choix pour le délégué adjoint
output$deputy_delegate_choices <- renderUI({
  # Dépendre de la classe sélectionnée ET du trigger de rafraîchissement
  req(selected_class())
  refresh_candidates() # Déclenche le rendu quand cette valeur change
  
  # Message de débogage
  showNotification(paste("Recherche candidats adjoints pour:", selected_class()), type = "message")
  
  # Récupérer les candidats pour cette classe et type
  candidates <- dbGetQuery(values$con, 
    "SELECT id, name, bio, program FROM delegate_candidates 
     WHERE classe = ? AND position_type = 'adjoint' ORDER BY name",
    params = list(selected_class())
  )
  
  # Message de débogage pour le nombre de candidats trouvés
  showNotification(paste("Candidats adjoints trouvés:", nrow(candidates)), type = "message")
  
  if (nrow(candidates) == 0) {
    return(div(class = "alert alert-warning text-center", 
               style = "margin: 20px; padding: 20px;",
               icon("exclamation-triangle", class = "me-2"),
               h4("Aucun candidat adjoint disponible"),
               p(paste("Aucun candidat adjoint trouvé pour la classe", selected_class()))
    ))
  }
  
  # Affichage très visible et forcé
  div(
    # Titre très visible
    div(style = "background: linear-gradient(135deg, #28a745, #1e7e34); color: white; padding: 15px; border-radius: 8px; margin-bottom: 15px; text-align: center;",
      h3("🤝 CANDIDATS DÉLÉGUÉS ADJOINTS", style = "margin: 0; font-weight: bold;"),
      h4(paste("Classe:", selected_class()), style = "margin: 5px 0 0 0; color: #d4edda;")
    ),
    
    # Liste des candidats avec style très visible
    div(style = "background-color: #f0fff0; padding: 15px; border-radius: 8px;",
      lapply(1:nrow(candidates), function(i) {
        div(class = "candidate-item", 
            style = "background-color: white; border: 2px solid #28a745; border-radius: 8px; padding: 12px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          div(class = "form-check",
            tags$input(type = "radio", 
                      class = "form-check-input", 
                      name = "deputy_delegate_choice", 
                      id = paste0("deputy_", candidates$id[i]),
                      value = candidates$id[i],
                      style = "width: 20px; height: 20px; margin-right: 10px;"),
            tags$label(class = "form-check-label w-100", 
                      `for` = paste0("deputy_", candidates$id[i]),
                      style = "cursor: pointer;",
              div(
                h4(candidates$name[i], style = "color: #28a745; margin-bottom: 0; font-weight: bold;")
              )
            )
          )
        )
      })
    )
  )
})

# Traitement du vote pour les délégués
observeEvent(input$submit_delegate_vote, {
  # Vérifier que l'utilisateur est authentifié
  req(user$authenticated, user$id, user$year)
  
  # Vérifier que la classe de l'étudiant est définie
  if (is.null(user$year) || user$year == "") {
    showNotification("Erreur: Votre classe n'est pas définie. Veuillez vous reconnecter.", type = "error")
    return()
  }
  
  # Vérifier que la classe sélectionnée correspond à celle de l'étudiant
  if (is.null(selected_class()) || selected_class() != user$year) {
    showNotification("Erreur: Vous ne pouvez voter que pour les délégués de votre propre classe.", type = "error")
    return()
  }
  
  # Récupérer les choix depuis les inputs JavaScript
  main_choice <- input$main_delegate_choice
  deputy_choice <- input$deputy_delegate_choice
  
  # Vérifier qu'un choix a été fait pour au moins un type de délégué
  if (is.null(main_choice) && is.null(deputy_choice)) {
    showNotification("Veuillez choisir au moins un délégué pour voter.", type = "warning")
    return()
  }
  
  # Vérifier si l'utilisateur a déjà voté pour sa classe
  has_voted_main <- FALSE
  has_voted_deputy <- FALSE
  
  if (!is.null(main_choice) && main_choice != "") {
    existing_vote_main <- dbGetQuery(values$con, 
      "SELECT id FROM delegate_votes 
       WHERE voter_id = ? AND classe = ? AND position_type = 'delegue'",
      params = list(user$id, user$year)
    )
    has_voted_main <- nrow(existing_vote_main) > 0
  }
  
  if (!is.null(deputy_choice) && deputy_choice != "") {
    existing_vote_deputy <- dbGetQuery(values$con, 
      "SELECT id FROM delegate_votes 
       WHERE voter_id = ? AND classe = ? AND position_type = 'adjoint'",
      params = list(user$id, user$year)
    )
    has_voted_deputy <- nrow(existing_vote_deputy) > 0
  }
  
  # Si l'utilisateur a déjà voté, afficher un message
  if (has_voted_main && has_voted_deputy) {
    showNotification("Vous avez déjà voté pour les délégués de votre classe.", type = "warning")
    return()
  }
  
  # Enregistrer les votes (toujours pour la classe de l'étudiant)
  tryCatch({
    # Vote pour le délégué principal
    if (!is.null(main_choice) && main_choice != "" && !has_voted_main) {
      dbExecute(values$con, 
        "INSERT INTO delegate_votes (voter_id, candidate_id, classe, position_type) VALUES (?, ?, ?, 'delegue')",
        params = list(user$id, as.integer(main_choice), user$year)
      )
      showNotification("Vote pour délégué principal enregistré!", type = "message")
    }
    
    # Vote pour le délégué adjoint
    if (!is.null(deputy_choice) && deputy_choice != "" && !has_voted_deputy) {
      dbExecute(values$con, 
        "INSERT INTO delegate_votes (voter_id, candidate_id, classe, position_type) VALUES (?, ?, ?, 'adjoint')",
        params = list(user$id, as.integer(deputy_choice), user$year)
      )
      showNotification("Vote pour délégué adjoint enregistré!", type = "message")
    }
    
    # Notification de succès globale
    showNotification(paste("Votre vote a été enregistré avec succès pour la classe", user$year, "!"), type = "message")
    
  }, error = function(e) {
    showNotification(paste("Erreur lors de l'enregistrement du vote:", e$message), type = "error")
  })
})

# Résultats pour le délégué principal
output$main_delegate_results <- renderPlot({
  req(selected_class())
  
  # Récupérer les résultats
  results <- dbGetQuery(values$con, 
    "SELECT c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.classe = ? AND c.position_type = 'delegue'
     GROUP BY c.id
     ORDER BY votes DESC",
    params = list(selected_class())
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
  req(selected_class())
  
  # Récupérer les résultats
  results <- dbGetQuery(values$con, 
    "SELECT c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.classe = ? AND c.position_type = 'adjoint'
     GROUP BY c.id
     ORDER BY votes DESC",
    params = list(selected_class())
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
  req(selected_class())
  
  # Récupérer les résultats combinés
  results <- dbGetQuery(values$con, 
    "SELECT c.position_type, c.name, COUNT(v.id) as votes
     FROM delegate_candidates c
     LEFT JOIN delegate_votes v ON c.id = v.candidate_id
     WHERE c.classe = ?
     GROUP BY c.id
     ORDER BY c.position_type, votes DESC",
    params = list(selected_class())
  )
  
  if (nrow(results) == 0) {
    return(data.frame(Type = character(), Candidat = character(), Votes = integer()))
  }
  
  # Formater les types
  results$position_type <- ifelse(results$position_type == "delegue", "Délégué Principal", "Délégué Adjoint")
  
  # Renommer les colonnes
  names(results) <- c("Type", "Candidat", "Votes")
  
  results
}) 
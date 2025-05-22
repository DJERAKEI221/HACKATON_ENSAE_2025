# server/server_vote.R - Gestion des votes

# Variable réactive pour stocker le poste sélectionné
selected_vote_position <- reactiveVal(NULL)

# Générer les boutons pour chaque poste disponible
output$vote_position_buttons <- renderUI({
  # Récupérer les positions
  positions <- values$positions
  
  # Associer une icône à chaque type de poste
  position_icons <- list(
    "Président" = "crown",
    "Secrétaire" = "file-alt",
    "Conseiller" = "briefcase",
    "Chargé" = "bullhorn",
    "Club" = "users"
  )
  
  # Créer les boutons pour chaque poste
  position_buttons <- lapply(1:nrow(positions), function(i) {
    position_id <- positions$id[i]
    position_name <- positions$name[i]
    
    # Déterminer quelle icône utiliser en fonction du nom du poste
    icon_name <- "user-tie" # Icône par défaut
    
    # Chercher dans le nom du poste si un des mots clés est présent
    for (keyword in names(position_icons)) {
      if (grepl(keyword, position_name)) {
        icon_name <- position_icons[[keyword]]
        break
      }
    }
    
    # Gestion spécifique pour certains postes particuliers
    if (grepl("Informatique", position_name)) {
      icon_name <- "laptop-code"
    } else if (grepl("Junior Entreprise", position_name)) {
      icon_name <- "building"
    } else if (grepl("Leadership", position_name)) {
      icon_name <- "chess-king"
    } else if (grepl("Anglais", position_name)) {
      icon_name <- "language"
    } else if (grepl("Communication", position_name)) {
      icon_name <- "comments"
    }
    
    is_selected <- !is.null(selected_vote_position()) && selected_vote_position() == position_id
    is_voted <- !is.null(user$votes[[as.character(position_id)]])
    
    div(
      class = "mb-2",
      actionButton(
        paste0("vote_position_", position_id),
        div(
          class = "d-flex align-items-center justify-content-between w-100",
          div(
            class = "d-flex align-items-center",
            icon(icon_name, class = "me-2"),
            position_name
          ),
          if(is_voted) {
            icon("check-circle", class = "text-success")
          }
        ),
        class = paste0(
          "position-btn w-100 text-start ", 
          if(is_selected) "btn-primary" else "btn-outline-primary",
          if(is_voted) " vote-completed" else ""
        ),
        style = if(is_voted) "background-color: #f8f9fa; border-color: #28a745;" else ""
      )
    )
  })
  
  # Ajouter le JavaScript pour maintenir la sélection des boutons de position
  tagList(
    tags$script(HTML("
      $(document).ready(function() {
        // Gestion des boutons de position dans la page de vote
        $(document).on('click', '.position-btn', function() {
          // Supprimer la classe active de tous les boutons de position
          $('.position-btn').removeClass('btn-primary').addClass('btn-outline-primary');
          // Ajouter la classe active au bouton cliqué (sauf s'il a déjà été voté)
          if (!$(this).hasClass('vote-completed')) {
            $(this).removeClass('btn-outline-primary').addClass('btn-primary');
          }
        });
      });
    ")),
    position_buttons
  )
})

# Observer pour chaque bouton de poste
observe({
  positions <- values$positions
  
  lapply(positions$id, function(position_id) {
    local({
      btn_id <- paste0("vote_position_", position_id)
      
      observeEvent(input[[btn_id]], {
        selected_vote_position(position_id)
      })
    })
  })
})

# Affichage des candidats pour le poste sélectionné
output$candidates_panel <- renderUI({
  req(selected_vote_position(), user$authenticated)
  
  position_id <- selected_vote_position()
  
  candidates <- dbGetQuery(values$con, 
    "SELECT * FROM candidates WHERE position_id = ?",
    params = list(position_id)
  )
  
  if(nrow(candidates) == 0) {
    return(div(class = "alert alert-info",
                "Aucun candidat n'est encore enregistré pour ce poste"))
  }
  
  # Position name for display
  position_name <- values$positions$name[values$positions$id == position_id]
  
  # Check if user already voted for this position
  voted_for_position <- !is.null(user$votes[[as.character(position_id)]])
  
  tagList(
    h4(sprintf("Candidats pour: %s", position_name)),
    if(voted_for_position) {
      div(class = "alert alert-success",
          icon("check-circle"), 
          "Vous avez déjà voté pour ce poste.")
    },
    div(class = "candidates-grid",
        lapply(1:nrow(candidates), function(i) {
          div(class = "candidate-card",
              div(class = "candidate-photo",
                  icon("user-circle", class = "fa-3x")
              ),
              div(class = "candidate-name", candidates$name[i]),
              div(class = "candidate-program", 
                  p(candidates$program[i])
              ),
              if(!voted_for_position) {
                actionButton(paste0("vote_", candidates$id[i]),
                            "Voter", class = "btn-vote")
              }
          )
        })
    )
  )
})

# Observer pour gérer tous les votes possibles
observe({
  req(selected_vote_position())
  
  position_id <- selected_vote_position()
  
  candidates <- dbGetQuery(values$con, 
    "SELECT id FROM candidates WHERE position_id = ?",
    params = list(position_id)
  )
  
  for(i in 1:nrow(candidates)) {
    local({
      candidate_id <- candidates$id[i]
      vote_btn_id <- paste0("vote_", candidate_id)
      
      observeEvent(input[[vote_btn_id]], {
        # Vérifier si l'utilisateur a déjà voté
        if(!is.null(user$votes[[as.character(position_id)]])) {
          showNotification("Vous avez déjà voté pour ce poste", type = "error")
          return()
        }
        
        # Confirmation avant vote
        showModal(modalDialog(
          title = "Confirmation de vote",
          p("Êtes-vous sûr de vouloir voter pour ce candidat?"),
          p("Ce vote est définitif et ne pourra pas être modifié."),
          footer = tagList(
            modalButton("Annuler"),
            actionButton("confirm_vote", "Confirmer", class = "btn-success")
          )
        ))
        
        # Stocker temporairement les informations de vote
        user$temp_vote <- list(
          candidate_id = candidate_id,
          position_id = position_id
        )
      })
    })
  }
})

# Confirmation finale du vote
observeEvent(input$confirm_vote, {
  req(user$temp_vote)
  
  # Enregistrer le vote
  position_id <- user$temp_vote$position_id
  candidate_id <- user$temp_vote$candidate_id
  
  # Simulation d'enregistrement en base de données
  # En réalité, on utiliserait:
  # dbExecute(con, "INSERT INTO votes (voter_id, candidate_id, position_id, timestamp, hash)
  #           VALUES (?, ?, ?, datetime('now'), ?)",
  #           params = list(user$id, candidate_id, position_id, generate_hash(paste(user$id, position_id))))
  
  # Stocker dans l'état utilisateur
  user$votes[[as.character(position_id)]] <- candidate_id
  
  # Fermer la boîte de dialogue
  removeModal()
  
  # Afficher confirmation
  showNotification("Vote enregistré avec succès!", type = "message")
  
  # Actualiser l'affichage des candidats sans recharger toute la session
  # Ne pas utiliser session$reload() qui cause une déconnexion de la base de données
})

# Rechargement automatique de l'interface des candidats après un vote
observe({
  # Réagir aux changements dans la liste des votes de l'utilisateur
  req(user$votes)
  
  # Forcer le rafraîchissement de l'interface utilisateur
  invalidateLater(200)
})

# Mise à jour de la progression du vote
observe({
  req(user$authenticated)
  
  # Obtenir la liste de tous les postes
  all_positions <- dbGetQuery(values$con, "SELECT id FROM positions")$id
  total_positions <- length(all_positions)
  
  # Vérifier combien de postes ont déjà été votés
  if(length(user$votes) > 0) {
    voted_positions <- length(names(user$votes))
    progress_percent <- round((voted_positions / total_positions) * 100)
    
    # Mettre à jour la barre de progression
    session$sendCustomMessage(type = "update-vote-progress", 
                             list(percent = progress_percent, 
                                  text = paste0(progress_percent, "% des votes complétés")))
  } else {
    # Aucun vote, initialiser à 0%
    session$sendCustomMessage(type = "update-vote-progress", 
                             list(percent = 0, 
                                  text = "0% des votes complétés"))
  }
})

# Mise à jour de l'état de la confirmation du vote
observe({
  req(input$position)
  position_id <- input$position
  
  if(!is.null(user$votes[[as.character(position_id)]])) {
    # L'utilisateur a déjà voté pour ce poste
    candidate_id <- user$votes[[as.character(position_id)]]
    candidate_name <- dbGetQuery(values$con, "SELECT name FROM candidates WHERE id = ?", 
                               params = list(candidate_id))$name
    
    output$vote_confirmation_status <- renderUI({
      div(class = "vote-status vote-completed",
          icon("check-circle", class = "me-1"),
          paste0("Vous avez voté pour: ", candidate_name))
    })
  } else {
    # L'utilisateur n'a pas encore voté pour ce poste
    output$vote_confirmation_status <- renderUI({
      div(class = "vote-status vote-pending",
          icon("clock", class = "me-1"),
          "En attente de votre vote")
    })
  }
})

# JavaScript pour mettre à jour la barre de progression
output$vote_js <- renderUI({
  tags$script(HTML("
    Shiny.addCustomMessageHandler('update-vote-progress', function(message) {
      // Mettre à jour la barre de progression
      $('#vote_progress').css('width', message.percent + '%');
      $('#vote_progress').attr('aria-valuenow', message.percent);
      
      // Mettre à jour le texte de progression dans l'en-tête
      $('#vote_progress_text').text(message.text);
    });
  "))
}) 
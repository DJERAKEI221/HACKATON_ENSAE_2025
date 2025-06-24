# server/server_vote.R - Gestion des votes

# Installation et chargement des packages nécessaires
if (!require("lubridate")) {
  install.packages("lubridate")
}
library(lubridate)

# Configuration des dates et heures de vote
VOTE_START_DATE <- format(Sys.Date(), "%Y-%m-%d")  # Date d'aujourd'hui
VOTE_END_DATE <- "2025-12-31"    # Date de fin des votes (fin de l'année)
VOTE_START_TIME <- "00:00:00"    # Heure de début des votes (minuit)
VOTE_END_TIME <- "23:59:59"      # Heure de fin des votes (fin de journée)

# Fonction pour vérifier si le vote est ouvert
is_voting_open <- function() {
  current_datetime <- Sys.time()
  start_datetime <- as.POSIXct(paste(VOTE_START_DATE, VOTE_START_TIME))
  end_datetime <- as.POSIXct(paste(VOTE_END_DATE, VOTE_END_TIME))
  
  return(current_datetime >= start_datetime && current_datetime <= end_datetime)
}

# Fonction pour obtenir le temps restant avant l'ouverture ou après la fermeture
get_voting_time_info <- function() {
  current_datetime <- Sys.time()
  start_datetime <- as.POSIXct(paste(VOTE_START_DATE, VOTE_START_TIME))
  end_datetime <- as.POSIXct(paste(VOTE_END_DATE, VOTE_END_TIME))
  
  if (current_datetime < start_datetime) {
    time_left <- as.numeric(difftime(start_datetime, current_datetime, units = "mins"))
    hours_left <- floor(time_left / 60)
    mins_left <- round(time_left %% 60)
    
    return(list(
      status = "pending",
      message = paste("Les votes ouvriront le", format(start_datetime, "%d/%m/%Y à %H:%M")),
      time_left = time_left,
      time_left_text = if(hours_left > 0) {
        sprintf("%d heure(s) et %d minute(s)", hours_left, mins_left)
      } else {
        sprintf("%d minute(s)", mins_left)
      }
    ))
  } else if (current_datetime > end_datetime) {
    return(list(
      status = "closed",
      message = paste("Les votes sont fermés depuis le", format(end_datetime, "%d/%m/%Y à %H:%M")),
      time_left = 0,
      time_left_text = "0"
    ))
  } else {
    time_left <- as.numeric(difftime(end_datetime, current_datetime, units = "mins"))
    hours_left <- floor(time_left / 60)
    mins_left <- round(time_left %% 60)
    
    return(list(
      status = "open",
      message = paste("Les votes ferment le", format(end_datetime, "%d/%m/%Y à %H:%M")),
      time_left = time_left,
      time_left_text = if(hours_left > 0) {
        sprintf("%d heure(s) et %d minute(s)", hours_left, mins_left)
      } else {
        sprintf("%d minute(s)", mins_left)
      }
    ))
  }
}

# Variable réactive pour stocker le poste sélectionné
selected_vote_position <- reactiveVal(NULL)

# Gestion de l'affichage de l'interface de vote selon l'authentification et l'heure
output$login_warning <- renderUI({
  if (!is.null(user$authenticated) && user$authenticated) {
    # Vérifier si l'utilisateur est un administrateur
    if (!is.null(user$year) && user$year == "Administration") {
      # Cas spécial pour l'administrateur - masquer l'interface de vote
      shinyjs::hide("vote_interface")
      return(div(
        class = "alert alert-primary text-center", 
        style = "margin: 50px auto; max-width: 600px;",
        icon("shield-alt", class = "fa-2x mb-3"),
        h3("Mode Administrateur"),
        p("En tant qu'administrateur, vous n'êtes pas autorisé à participer au vote."),
        p("Vous avez accès aux fonctionnalités d'administration et aux statistiques de votes uniquement.")
      ))
    }
    
    # Vérifier si le vote est ouvert
    voting_status <- get_voting_time_info()
    
    if (voting_status$status == "open") {
      # Vote ouvert - afficher l'interface de vote
      shinyjs::show("vote_interface")
      return(NULL)
    } else {
      # Vote fermé ou en attente - masquer l'interface et afficher un message
      shinyjs::hide("vote_interface")
      return(div(
        class = "alert alert-warning text-center", 
        style = "margin: 50px auto; max-width: 600px;",
        icon("clock", class = "fa-2x mb-3"),
        h3(if(voting_status$status == "pending") "Vote en attente" else "Vote fermé"),
        p(voting_status$message),
        if(voting_status$status == "pending") {
          p(sprintf("Temps restant avant l'ouverture : %s", voting_status$time_left_text))
        } else if(voting_status$status == "closed") {
          p("Les votes sont terminés.")
        }
      ))
    }
  } else {
    # Utilisateur non authentifié - masquer l'interface et afficher un message
    shinyjs::hide("vote_interface")
    div(class = "alert alert-warning text-center", style = "margin: 50px auto; max-width: 600px;",
      icon("exclamation-triangle", class = "fa-2x mb-3"),
      h3("Authentification requise"),
      p("Vous devez vous authentifier pour accéder à l'interface de vote."),
      p("Veuillez vous connecter avec votre identifiant étudiant."),
      actionButton("go_to_auth", "Se connecter", 
                   class = "btn btn-primary btn-lg",
                   onclick = "Shiny.setInputValue('navbar_goto_auth', Math.random());")
    )
  }
})

# Observer pour rediriger vers l'authentification
observeEvent(input$navbar_goto_auth, {
  updateNavbarPage(session, "main_navbar", selected = "Authentification")
})

# Observer pour gérer l'authentification et la vérification de l'heure
observeEvent(input$login_button, {
  # Vérifier l'authentification
  if (!is.null(user$authenticated) && user$authenticated) {
    # Vérifier si le vote est ouvert
    voting_status <- get_voting_time_info()
    
    if (voting_status$status == "open") {
      # Vote ouvert - autoriser l'accès
      updateNavbarPage(session, "main_navbar", selected = "Vote")
    } else {
      # Vote fermé ou en attente - bloquer l'accès et afficher un message
      showModal(modalDialog(
        title = if(voting_status$status == "pending") "Vote en attente" else "Vote fermé",
        div(
          class = "text-center",
          icon("clock", class = "fa-3x mb-3"),
          p(voting_status$message),
          if(voting_status$status == "pending") {
            p(sprintf("Temps restant avant l'ouverture : %s", voting_status$time_left_text))
          } else if(voting_status$status == "closed") {
            p("Les votes sont terminés.")
          }
        ),
        footer = modalButton("Fermer"),
        size = "m"
      ))
      
      # Déconnecter l'utilisateur
      user$authenticated <- FALSE
      user$id <- NULL
      user$votes <- list()
    }
  }
})

# Observer pour empêcher la navigation vers les autres pages si le vote n'est pas ouvert
observeEvent(input$main_navbar, {
  if (!is.null(user$authenticated) && user$authenticated) {
    voting_status <- get_voting_time_info()
    
    if (voting_status$status != "open" && input$main_navbar != "Authentification") {
      # Bloquer la navigation et afficher un message
      showModal(modalDialog(
        title = if(voting_status$status == "pending") "Vote en attente" else "Vote fermé",
        div(
          class = "text-center",
          icon("clock", class = "fa-3x mb-3"),
          p(voting_status$message),
          if(voting_status$status == "pending") {
            p(sprintf("Temps restant avant l'ouverture : %s", voting_status$time_left_text))
          } else if(voting_status$status == "closed") {
            p("Les votes sont terminés.")
          }
        ),
        footer = modalButton("Fermer"),
        size = "m"
      ))
      
      # Revenir à la page d'authentification
      updateNavbarPage(session, "main_navbar", selected = "Authentification")
    }
  }
})

# Générer les boutons pour chaque poste disponible
output$vote_position_buttons <- renderUI({
  # Récupérer les positions depuis la base de données avec catégories
  positions <- tryCatch({
    dbGetQuery(values$con, "SELECT id, name, description, category FROM positions ORDER BY category, order_priority, name")
  }, error = function(e) {
    cat("Erreur lors de la récupération des positions:", e$message, "\n")
    return(data.frame(id = integer(), name = character(), description = character(), category = character()))
  })
  
  if (nrow(positions) == 0) {
    return(div(class = "alert alert-info",
               "Aucun poste électoral n'est disponible pour le moment."))
  }
  
  # Grouper les postes par catégorie
  categories <- unique(positions$category)
  
  category_sections <- lapply(categories, function(category) {
    category_positions <- positions[positions$category == category, ]
    
    # Créer les boutons pour cette catégorie
    position_buttons <- lapply(1:nrow(category_positions), function(i) {
      position_id <- category_positions$id[i]
      position_name <- category_positions$name[i]
      
      # Déterminer quelle icône utiliser en fonction du nom du poste
      icon_name <- if(grepl("Président", position_name)) {
        "crown"
      } else if(grepl("Secrétaire", position_name)) {
        "file-alt"
      } else if(grepl("communication", position_name, ignore.case = TRUE)) {
        "bullhorn"
      } else if(grepl("Junior Entreprise|JE", position_name)) {
        "building"
      } else if(grepl("leadership", position_name, ignore.case = TRUE)) {
        "chess-king"
      } else if(grepl("anglais", position_name, ignore.case = TRUE)) {
        "language"
      } else if(grepl("informatique", position_name, ignore.case = TRUE)) {
        "laptop-code"
      } else if(grepl("Conseiller", position_name)) {
        "user-tie"
      } else if(grepl("Tésorier", position_name)) {
        "coins"
      } else if(grepl("Commisaire", position_name)) {
        "balance-scale"
      } else if(grepl("presse", position_name, ignore.case = TRUE)) {
        "newspaper"
      } else if(grepl("Chargé", position_name)) {
        "user-cog"
      } else if(grepl("affaires sociales", position_name, ignore.case = TRUE)) {
        "heart"
      } else if(grepl("culturelles|sportives", position_name, ignore.case = TRUE)) {
        "palette"
      } else if(grepl("relations extérieures", position_name, ignore.case = TRUE)) {
        "handshake"
      } else {
        "users"
      }
      
      is_selected <- !is.null(selected_vote_position()) && selected_vote_position() == position_id
      
      # Vérifier si l'utilisateur a déjà voté pour ce poste en consultant la base de données
      is_voted <- FALSE
      if(!is.null(user$id)) {
        existing_votes <- dbGetQuery(values$con,
                                     "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                     params = list(user$id, position_id))
        is_voted <- nrow(existing_votes) > 0
      }

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
          disabled = if(is_voted) "disabled" else NULL,
          style = if(is_voted) "background-color: #f8f9fa; border-color: #28a745;" else ""
        )
      )
    })
    
    # Retourner la section de catégorie
    div(class = "vote-category-section mb-4",
      h5(class = "vote-category-title", 
        icon(if(category == "Bureau exécutif") "users-cog" else "building", class = "me-2"),
        category
      ),
      div(class = "vote-positions-wrapper", position_buttons)
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
    category_sections
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
  voted_for_position <- FALSE
  if(!is.null(user$id)) {
    existing_votes <- dbGetQuery(values$con,
                                 "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                 params = list(user$id, position_id))
    voted_for_position <- nrow(existing_votes) > 0
  }
  
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
        # Vérifier si l'utilisateur est un administrateur
        if (!is.null(user$year) && user$year == "Administration") {
          showNotification("Les administrateurs ne sont pas autorisés à voter.", type = "error")
          return()
        }
        
        # Vérifier si le vote est ouvert
        if (!is_voting_open()) {
          showNotification("Le vote n'est pas ouvert à cette heure.", type = "error")
          return()
        }
        
        # Vérifier si l'utilisateur a déjà voté
        existing_votes <- dbGetQuery(values$con,
                                     "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                     params = list(user$id, position_id))
        if(nrow(existing_votes) > 0) {
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
  req(user$temp_vote, user$id, values$con)
  
  # Vérifier si l'utilisateur est un administrateur
  if (!is.null(user$year) && user$year == "Administration") {
    showNotification("Les administrateurs ne sont pas autorisés à voter.", type = "error")
    removeModal()
    return()
  }
  
  # Vérifier si le vote est toujours ouvert
  if (!is_voting_open()) {
    showNotification("Le vote n'est plus ouvert à cette heure.", type = "error")
    removeModal()
    return()
  }
  
  # Enregistrer le vote
  position_id <- user$temp_vote$position_id
  candidate_id <- user$temp_vote$candidate_id
  voter_id <- user$id
  
  # Vérifier une dernière fois si l'utilisateur a déjà voté pour ce poste
  existing_votes <- dbGetQuery(values$con,
                               "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                               params = list(voter_id, position_id))
  
  if(nrow(existing_votes) > 0) {
    showNotification("Vous avez déjà voté pour ce poste.", type = "error")
    removeModal()
    return()
  }
  
  # Générer un hash unique pour le vote
  vote_hash <- generate_hash(paste(voter_id, candidate_id, position_id, Sys.time(), sep = "_"))
  
  # Enregistrer le vote en base de données
  result <- dbExecute(values$con, 
                      "INSERT INTO votes (voter_id, candidate_id, position_id, hash) VALUES (?, ?, ?, ?)",
                      params = list(voter_id, candidate_id, position_id, vote_hash))
  
  if(result == 1) {
    # Stocker dans l'état utilisateur pour l'interface
    user$votes[[as.character(position_id)]] <- candidate_id
    
    # Marquer le succès du vote
    values$vote_success <- TRUE
    
    # Incrémenter le compteur de votes pour déclencher les mises à jour des vues
    if (is.null(values$votes)) {
      isolate({
        values$votes <- 1
      })
      cat("Initialisation du compteur de votes après le premier vote\n")
    } else {
      isolate({
        values$votes <- values$votes + 1
      })
      cat("Incrémentation du compteur de votes:", isolate(values$votes), "\n")
    }
    
    # Fermer la boîte de dialogue
    removeModal()
    
    # Afficher confirmation
    showNotification("Vote enregistré avec succès!", type = "message")
    
    # Nettoyer les données temporaires
    user$temp_vote <- NULL
  } else {
    showNotification("Erreur lors de l'enregistrement du vote.", type = "error")
    removeModal()
  }
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
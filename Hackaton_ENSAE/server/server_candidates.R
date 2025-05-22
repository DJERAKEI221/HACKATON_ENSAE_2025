# server/server_candidates.R - Gestion des profils des candidats

# Variable réactive pour stocker les postes sélectionnés
selected_positions <- reactiveVal(c("all"))

# Mise à jour du sélecteur de postes pour les filtres
observe({
  updateSelectInput(session, "filter_position", 
                   choices = c("Tous les postes" = "all", 
                              setNames(values$positions$id, values$positions$name)))
})

# Génération des cases à cocher avec icônes pour chaque poste
output$position_checkboxes <- renderUI({
  # Vérifier si la connexion est valide
  if (!dbIsValid(values$con)) {
    # Tentative de reconnexion
    tryCatch({
      values$con <- dbConnect(RSQLite::SQLite(), "data/election_db.sqlite")
      showNotification("Reconnexion à la base de données réussie", type = "message")
    }, error = function(e) {
      return(div(class = "alert alert-danger",
                 icon("exclamation-triangle"), "Erreur de connexion à la base de données. Veuillez rafraîchir la page."))
    })
  }
  
  # Récupérer tous les postes avec gestion d'erreur
  tryCatch({
    positions <- dbGetQuery(values$con, "SELECT id, name FROM positions ORDER BY name")
    
    # Si la requête ne retourne pas de résultats, proposer des postes par défaut
    if (nrow(positions) == 0) {
      positions <- data.frame(
        id = c(1, 2, 3, 4, 5),
        name = c("Président", "Secrétaire", "Trésorier", "Chargé de Communication", "Conseiller")
      )
    }
    
    # Associer une icône à chaque type de poste
    position_icons <- list(
      "Président" = "crown",
      "Secrétaire" = "file-alt",
      "Conseiller" = "briefcase",
      "Chargé" = "bullhorn",
      "Club" = "users"
    )
    
    # Créer la case à cocher "Tous les postes"
    all_checkbox <- div(class = "position-filter-item mb-2",
      div(class = paste0("form-check d-flex align-items-center", if("all" %in% selected_positions()) " active-filter" else ""),
        tags$input(type = "checkbox", id = "filter_all", class = "form-check-input me-2",
                  checked = "all" %in% selected_positions(),
                  onclick = "Shiny.setInputValue('filter_all_clicked', Math.random())"),
        tags$label(`for` = "filter_all", class = "form-check-label d-flex align-items-center",
                  icon("th-large", class = "me-2 text-primary"), "Tous les postes")
      )
    )
    
    # Créer les cases à cocher pour chaque poste
    position_checkboxes <- lapply(1:nrow(positions), function(i) {
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
      
      is_selected <- as.character(position_id) %in% selected_positions() || "all" %in% selected_positions()
      
      div(class = "position-filter-item mb-2",
        div(class = paste0("form-check d-flex align-items-center", if(is_selected) " active-filter" else ""),
          tags$input(type = "checkbox", id = paste0("filter_", position_id), 
                    class = "form-check-input me-2 position-checkbox",
                    `data-position-id` = position_id,
                    checked = is_selected,
                    onclick = sprintf("Shiny.setInputValue('filter_position_clicked', {id: %s, value: this.checked, random: Math.random()})", position_id)),
          tags$label(`for` = paste0("filter_", position_id), 
                    class = "form-check-label d-flex align-items-center",
                    icon(icon_name, class = "me-2 text-primary"), 
                    position_name)
        )
      )
    })
    
    # Ajouter du CSS pour les filtres actifs
    css <- tags$style(HTML("
      .active-filter {
        background-color: rgba(13, 110, 253, 0.1);
        border-radius: 4px;
        padding: 5px 10px;
        border-left: 3px solid #0d6efd;
      }
    "))
    
    # Combiner tous les éléments
    tagList(
      css,
      all_checkbox,
      hr(),
      position_checkboxes
    )
  }, error = function(e) {
    # En cas d'erreur, afficher un message d'erreur convivial
    div(
      class = "alert alert-warning", 
      style = "border-radius: 10px; background: linear-gradient(145deg, #fff9e6, #fff5d6); border-left: 4px solid #ffc107; padding: 15px;",
      div(class = "d-flex align-items-center",
        icon("exclamation-triangle", class = "fa-2x me-3 text-warning"),
        div(
          h4("Problème de connexion", class = "alert-heading mb-2"),
          p("Impossible d'accéder à la liste des postes. Veuillez rafraîchir la page ou contacter l'administrateur."),
          p("Code erreur: ", strong(conditionMessage(e)))
        )
      )
    )
  })
})

# Gestion du clic sur "Tous les postes"
observeEvent(input$filter_all_clicked, {
  if ("all" %in% selected_positions()) {
    # Désélectionner "Tous les postes"
    selected_positions(character(0))
  } else {
    # Sélectionner "Tous les postes"
    selected_positions("all")
  }
})

# Gestion du clic sur un poste spécifique
observeEvent(input$filter_position_clicked, {
  position_id <- as.character(input$filter_position_clicked$id)
  is_checked <- input$filter_position_clicked$value
  
  current_selected <- selected_positions()
  
  if ("all" %in% current_selected) {
    # Si "Tous les postes" est sélectionné, on le retire et on ajoute tous les autres postes sauf celui qu'on vient de décocher
    all_positions <- as.character(dbGetQuery(values$con, "SELECT id FROM positions")$id)
    if (!is_checked) {
      # On déselectionne un poste spécifique
      current_selected <- setdiff(all_positions, position_id)
    } else {
      # Ce cas ne devrait pas arriver normalement, mais par sécurité
      current_selected <- all_positions
    }
  } else {
    # Gestion normale des cases à cocher individuelles
    if (is_checked) {
      # Ajouter le poste sélectionné
      current_selected <- c(current_selected, position_id)
    } else {
      # Retirer le poste désélectionné
      current_selected <- setdiff(current_selected, position_id)
    }
    
    # Si tous les postes sont sélectionnés, remplacer par "all"
    all_positions <- as.character(dbGetQuery(values$con, "SELECT id FROM positions")$id)
    if (length(setdiff(all_positions, current_selected)) == 0) {
      current_selected <- "all"
    }
  }
  
  # Mettre à jour les positions sélectionnées
  selected_positions(current_selected)
})

# Réinitialisation des filtres
observeEvent(input$reset_filters, {
  selected_positions("all")
})

# Liste des candidats filtrée par poste(s) sélectionné(s)
output$candidates_list <- renderUI({
  # Vérifier si la connexion est valide
  if (!dbIsValid(values$con)) {
    # Tentative de reconnexion
    tryCatch({
      values$con <- dbConnect(RSQLite::SQLite(), "data/election_db.sqlite")
    }, error = function(e) {
      return(div(class = "alert alert-danger",
                 icon("exclamation-triangle"), "Erreur de connexion à la base de données. Veuillez rafraîchir la page."))
    })
  }

  position_filter <- selected_positions()
  
  # Construire la requête SQL selon le filtre avec gestion d'erreur
  tryCatch({
    if("all" %in% position_filter || length(position_filter) == 0) {
      candidates <- dbGetQuery(values$con, "
        SELECT c.id, c.name, c.position_id, p.name as position_name 
        FROM candidates c
        JOIN positions p ON c.position_id = p.id
        ORDER BY p.name, c.name")
    } else {
      # Utiliser une requête paramétrée avec IN pour les filtres multiples
      position_placeholders <- paste(rep("?", length(position_filter)), collapse = ",")
      candidates <- dbGetQuery(values$con, sprintf("
        SELECT c.id, c.name, c.position_id, p.name as position_name 
        FROM candidates c
        JOIN positions p ON c.position_id = p.id
        WHERE c.position_id IN (%s)
        ORDER BY p.name, c.name", position_placeholders), 
        params = as.list(position_filter))
    }
    
    if(nrow(candidates) == 0) {
      return(div(class = "alert", style = "background: linear-gradient(145deg, rgba(63, 81, 181, 0.1), rgba(63, 81, 181, 0.05)); border-left: 4px solid #3f51b5; color: #303f9f; border-radius: 10px; padding: 15px; text-align: center;", 
                 icon("search", class = "me-2 text-primary"),
                 "Aucun candidat trouvé"))
    }
    
    # Créer une liste cliquable de candidats
    div(
      class = "list-group candidates-list",
      lapply(1:nrow(candidates), function(i) {
        tags$a(
          class = "list-group-item list-group-item-action d-flex justify-content-between align-items-center",
          href = "#",
          `data-id` = candidates$id[i],
          id = paste0("candidate_", candidates$id[i]),
          onclick = sprintf("Shiny.setInputValue('selected_candidate', %s)", candidates$id[i]),
          
          div(
            strong(candidates$name[i]),
            tags$br(),
            tags$small(class = "text-muted", candidates$position_name[i])
          ),
          
          span(class = "badge bg-primary rounded-pill", icon("chevron-right"))
        )
      })
    )
  }, error = function(e) {
    # En cas d'erreur, afficher un message d'erreur convivial
    div(
      class = "alert alert-warning", 
      style = "border-radius: 10px; background: linear-gradient(145deg, #fff9e6, #fff5d6); border-left: 4px solid #ffc107; padding: 15px;",
      div(class = "d-flex align-items-center",
        icon("exclamation-triangle", class = "fa-2x me-3 text-warning"),
        div(
          h4("Problème d'accès aux données", class = "alert-heading mb-2"),
          p("Impossible de récupérer la liste des candidats. Veuillez rafraîchir la page ou contacter l'administrateur."),
          p("Code erreur: ", strong(conditionMessage(e)))
        )
      )
    )
  })
})

# Profil détaillé du candidat
output$candidate_profile <- renderUI({
  # Ajouter un JavaScript pour masquer la section vidéo quand aucun candidat n'est sélectionné
  if(!length(input$selected_candidate) || is.na(input$selected_candidate)) {
    # Aucun candidat sélectionné, masquer la vidéo et le programme
    session$sendCustomMessage(type = "toggle-campaign-video", message = list(show = FALSE))
    return(div(class = "alert text-center", style = "background: linear-gradient(145deg, rgba(63, 81, 181, 0.1), rgba(63, 81, 181, 0.05)); border-left: 4px solid #3f51b5; color: #303f9f; border-radius: 10px; padding: 15px;", 
               icon("info-circle", class = "me-2 text-primary"),
               "Sélectionnez un candidat pour voir son profil détaillé"))
  }
  
  req(input$selected_candidate)
  
  # Vérifier si le candidat est dans les filtres actuels
  position_filter <- selected_positions()
  
  # Récupérer les données du candidat
  candidate <- dbGetQuery(values$con, "
    SELECT c.*, p.name as position_name 
    FROM candidates c
    JOIN positions p ON c.position_id = p.id
    WHERE c.id = ?", 
    params = list(input$selected_candidate))
  
  if(nrow(candidate) == 0) {
    # Candidat non trouvé, masquer la vidéo
    session$sendCustomMessage(type = "toggle-campaign-video", message = list(show = FALSE))
    return(div(class = "alert", style = "background: linear-gradient(145deg, rgba(220, 53, 69, 0.1), rgba(220, 53, 69, 0.05)); border-left: 4px solid #dc3545; color: #721c24; border-radius: 10px; padding: 15px;", 
                icon("exclamation-triangle", class = "me-2 text-danger"),
                "Candidat non trouvé"))
  }
  
  # Vérifier si le poste du candidat est dans les filtres actuels
  if(!("all" %in% position_filter) && !(as.character(candidate$position_id) %in% position_filter)) {
    # Le candidat n'est pas dans les filtres actuels, masquer son profil, la vidéo et le programme
    session$sendCustomMessage(type = "toggle-campaign-video", message = list(show = FALSE))
    return(div(class = "alert", style = "background: linear-gradient(145deg, rgba(63, 81, 181, 0.1), rgba(63, 81, 181, 0.05)); border-left: 4px solid #3f51b5; color: #303f9f; border-radius: 10px; padding: 15px;", 
                icon("info-circle", class = "me-2 text-primary"),
                "Ce candidat n'est pas dans les filtres actuellement sélectionnés. Veuillez ajuster vos filtres pour voir son profil."))
  }
  
  # Candidat valide, afficher la vidéo et le programme
  session$sendCustomMessage(type = "toggle-campaign-video", message = list(show = TRUE))
  
  # Image par défaut si aucune photo n'est disponible
  photo_url <- if(is.null(candidate$photo_url) || is.na(candidate$photo_url) || candidate$photo_url == "") {
    "images/default_candidate.png"
  } else {
    candidate$photo_url
  }
  
  # Biographie par défaut si non disponible
  bio <- if(is.null(candidate$bio) || is.na(candidate$bio) || candidate$bio == "") {
    "Aucune biographie disponible."
  } else {
    candidate$bio
  }
  
  # Programme par défaut si non disponible
  program <- if(is.null(candidate$program) || is.na(candidate$program) || candidate$program == "") {
    "Aucun programme disponible."
  } else {
    candidate$program
  }
  
  # Créer la carte de profil
  div(class = "candidate-profile-card",
      div(class = "row",
          column(4,
                 div(class = "text-center",
                     img(src = photo_url, class = "candidate-photo img-fluid rounded-circle mb-3", 
                         alt = paste("Photo de", candidate$name)),
                     h3(candidate$name),
                     div(class = "badge bg-primary mb-3", candidate$position_name)
                 )
          ),
          column(8,
                 bslib::card(class = "bio-card shadow-sm mb-3", 
                   bslib::card_header(class = "bg-light",
                     div(class = "d-flex align-items-center justify-content-center", 
                       icon("user-graduate", class = "me-2 text-primary"),
                       h4("Biographie", class = "mb-0")
                     )
                   ),
                   bslib::card_body(
                     div(class = "bio-content p-2",
                       p(bio)
                     )
                   )
                 )
          )
      )
  )
})

# Affichage du programme électoral du candidat dans la nouvelle section
output$candidate_program <- renderUI({
  req(input$selected_candidate)
  
  # Récupérer les données du candidat
  candidate <- dbGetQuery(values$con, "
    SELECT c.*, p.name as position_name 
    FROM candidates c
    JOIN positions p ON c.position_id = p.id
    WHERE c.id = ?", 
    params = list(input$selected_candidate))
  
  if(nrow(candidate) == 0) {
    return(div(class = "alert alert-info", "Aucun programme disponible."))
  }
  
  # Programme par défaut si non disponible
  program <- if(is.null(candidate$program) || is.na(candidate$program) || candidate$program == "") {
    "Aucun programme disponible pour ce candidat."
  } else {
    candidate$program
  }
  
  div(
    h5(paste("Programme de", candidate$name, "pour le poste de", candidate$position_name), 
       class = "mb-3 text-primary"),
    p(program)
  )
})

# Gestion du bouton de vote dans la nouvelle interface
observeEvent(input$vote_for_candidate, {
  req(input$selected_candidate)
  
  # Vérifier si l'utilisateur est connecté
  if(!user$authenticated) {
    showNotification("Vous devez être connecté pour voter.", type = "warning")
    updateNavbarPage(session, "main_navbar", selected = "Login")
    return()
  }
  
  # Récupérer les informations sur le candidat
  candidate_info <- dbGetQuery(values$con, "
    SELECT c.id, c.position_id, p.name as position_name 
    FROM candidates c
    JOIN positions p ON c.position_id = p.id
    WHERE c.id = ?", 
    params = list(input$selected_candidate))
  
  if(nrow(candidate_info) > 0) {
    # Vérifier si l'utilisateur a déjà voté pour ce poste
    position_id <- candidate_info$position_id[1]
    
    if(!is.null(user$votes[[as.character(position_id)]])) {
      showNotification("Vous avez déjà voté pour ce poste", type = "error")
      return()
    }
    
    # Rediriger vers l'onglet de vote avec le bon poste présélectionné
    updateSelectInput(session, "position", selected = position_id)
    updateNavbarPage(session, "main_navbar", selected = "Vote")
  }
})

# Gestion du vote direct depuis la page profil
observe({
  lapply(dbGetQuery(values$con, "SELECT id FROM candidates")$id, function(candidate_id) {
    button_id <- paste0("vote_direct_", candidate_id)
    
    observeEvent(input[[button_id]], {
      # Récupérer les informations sur le candidat
      candidate_info <- dbGetQuery(values$con, "
        SELECT c.id, c.position_id, p.name as position_name 
        FROM candidates c
        JOIN positions p ON c.position_id = p.id
        WHERE c.id = ?", 
        params = list(candidate_id))
      
      if(nrow(candidate_info) > 0) {
        # Vérifier si l'utilisateur a déjà voté pour ce poste
        position_id <- candidate_info$position_id[1]
        
        if(!is.null(user$votes[[as.character(position_id)]])) {
          showNotification("Vous avez déjà voté pour ce poste", type = "error")
          return()
        }
        
        # Rediriger vers l'onglet de vote avec le bon poste présélectionné
        updateSelectInput(session, "position", selected = position_id)
        updateNavbarPage(session, "main_navbar", selected = "Vote")
      }
    })
  })
}) 
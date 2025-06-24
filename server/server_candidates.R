# server/server_candidates.R - Gestion moderne et élégante des candidats

# Variables réactives pour les filtres et l'état
selected_positions_filter <- reactiveVal(c())
current_search_term <- reactiveVal("")
view_mode <- reactiveVal("grid")
sort_by <- reactiveVal("position")

# Statistiques générales pour l'en-tête
output$total_candidates_count <- renderText({
  tryCatch({
    # Compter seulement les candidats du bureau/départements (exclure délégués)
    bureau_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM candidates")$count
    as.character(bureau_count)
  }, error = function(e) "0")
})

output$total_positions_count <- renderText({
    tryCatch({
    # Compter seulement les postes du bureau/départements (exclure délégués)
    bureau_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM positions")$count
    as.character(bureau_count)
  }, error = function(e) "0")
})

# Génération des filtres pour le Bureau exécutif
output$bureau_filters <- renderUI({
  tryCatch({
    # Récupérer les postes du bureau exécutif avec candidats
    bureau_positions <- dbGetQuery(values$con, 
      "SELECT DISTINCT p.id, p.name, p.order_priority 
       FROM positions p 
       JOIN candidates c ON p.id = c.position_id 
       WHERE p.category = 'Bureau exécutif'
       ORDER BY p.order_priority, p.name"
    )
    
    if(nrow(bureau_positions) == 0) {
      return(p("Aucun candidat pour le bureau exécutif", class = "text-muted"))
    }
    
    # Créer les chips de filtres
    filter_chips <- lapply(1:nrow(bureau_positions), function(i) {
      position <- bureau_positions[i, ]
      is_active <- position$id %in% selected_positions_filter()
      
      actionButton(
        inputId = paste0("filter_position_", position$id),
        label = position$name,
        class = paste("filter-chip", if(is_active) "active" else ""),
        onclick = sprintf("Shiny.setInputValue('toggle_position_filter', {id: %s, random: Math.random()})", position$id)
      )
    })
    
    div(class = "filter-chips-wrapper", filter_chips)
    
  }, error = function(e) {
    div(class = "alert alert-warning", "Erreur lors du chargement des filtres bureau")
  })
})
    
# Génération des filtres pour les Départements permanents
output$departements_filters <- renderUI({
  tryCatch({
    # Récupérer les postes des départements permanents avec candidats
    dept_positions <- dbGetQuery(values$con, 
      "SELECT DISTINCT p.id, p.name, p.order_priority 
       FROM positions p 
       JOIN candidates c ON p.id = c.position_id 
       WHERE p.category = 'Départements permanents'
       ORDER BY p.order_priority, p.name"
    )
    
    if(nrow(dept_positions) == 0) {
      return(p("Aucun candidat pour les départements", class = "text-muted"))
    }
    
    # Créer les chips de filtres
    filter_chips <- lapply(1:nrow(dept_positions), function(i) {
      position <- dept_positions[i, ]
      is_active <- position$id %in% selected_positions_filter()
      
      actionButton(
        inputId = paste0("filter_position_", position$id),
        label = position$name,
        class = paste("filter-chip", if(is_active) "active" else ""),
        onclick = sprintf("Shiny.setInputValue('toggle_position_filter', {id: %s, random: Math.random()})", position$id)
      )
    })
    
    div(class = "filter-chips-wrapper", filter_chips)
    
  }, error = function(e) {
    div(class = "alert alert-warning", "Erreur lors du chargement des filtres départements")
  })
})

# Affichage du nombre de filtres actifs
output$active_filters_display <- renderUI({
  active_count <- length(selected_positions_filter())
  search_active <- !is.null(current_search_term()) && nchar(trimws(current_search_term())) > 0
  
  total_filters <- active_count + if(search_active) 1 else 0
  
  if(total_filters > 0) {
    div(class = "active-filters-badge",
      icon("filter", class = "me-1"),
      paste(total_filters, "filtre(s) actif(s)")
    )
  }
})

# Gestion du toggle des filtres de position
observeEvent(input$toggle_position_filter, {
  if(!is.null(input$toggle_position_filter)) {
    position_id <- input$toggle_position_filter$id
    current_filters <- selected_positions_filter()
  
    if(position_id %in% current_filters) {
      # Retirer le filtre
      new_filters <- current_filters[current_filters != position_id]
    } else {
      # Ajouter le filtre
      new_filters <- c(current_filters, position_id)
    }
    
    selected_positions_filter(new_filters)
  }
})

# Réinitialisation des filtres
observeEvent(input$reset_all_filters, {
  selected_positions_filter(c())
  current_search_term("")
  updateTextInput(session, "candidate_search", value = "")
})

# Effacer la recherche
observeEvent(input$clear_search, {
  current_search_term("")
  updateTextInput(session, "candidate_search", value = "")
})

# Mise à jour du terme de recherche
observeEvent(input$candidate_search, {
  current_search_term(input$candidate_search)
})

# Gestion des modes d'affichage
observeEvent(input$grid_view, {
  view_mode("grid")
})

observeEvent(input$list_view, {
  view_mode("list")
})

observeEvent(input$card_view, {
  view_mode("card")
})

# Gestion du tri
observeEvent(input$sort_by, {
  sort_by(input$sort_by)
})

# Gestion des boutons hero
observeEvent(input$scroll_to_candidates, {
  runjs("document.querySelector('.candidates-main-area').scrollIntoView({behavior: 'smooth'});")
})



# Résumé des résultats
output$results_summary <- renderText({
    tryCatch({
    candidates <- get_filtered_candidates()
    paste(nrow(candidates), "candidat(s) affiché(s)")
  }, error = function(e) "0 candidat affiché")
})

# Fonction pour récupérer les candidats filtrés avec tri
get_filtered_candidates <- reactive({
  tryCatch({
    # Requête de base
    query <- "
      SELECT c.*, p.name as position_name, p.description as position_description, 
             p.category, p.order_priority
        FROM candidates c
        JOIN positions p ON c.position_id = p.id
      WHERE 1=1
    "
    params <- list()
    
    # Filtrage par positions sélectionnées
    selected_positions <- selected_positions_filter()
    if(length(selected_positions) > 0) {
      placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
      query <- paste(query, "AND c.position_id IN (", placeholders, ")")
      params <- c(params, selected_positions)
    }
    
    # Filtrage par terme de recherche
    search_term <- current_search_term()
    if(!is.null(search_term) && nchar(trimws(search_term)) > 0) {
      query <- paste(query, "AND LOWER(c.name) LIKE LOWER(?)")
      params <- c(params, paste0("%", trimws(search_term), "%"))
    }
    
    # Tri selon la sélection
    sort_option <- sort_by()
    if(sort_option == "name") {
      query <- paste(query, "ORDER BY c.name")
    } else if(sort_option == "category") {
      query <- paste(query, "ORDER BY p.category, p.order_priority, c.name")
    } else { # position (défaut)
      query <- paste(query, "ORDER BY p.order_priority, c.name")
    }
    
    # Exécuter la requête
    if(length(params) > 0) {
      candidates <- dbGetQuery(values$con, query, params = params)
    } else {
      candidates <- dbGetQuery(values$con, query)
    }
    
    return(candidates)
    
  }, error = function(e) {
    data.frame(id = integer(0), name = character(0), position_id = integer(0),
               program = character(0), bio = character(0), photo_url = character(0),
               position_name = character(0), position_description = character(0),
               category = character(0), order_priority = integer(0))
  })
})

# Fonction pour générer les boutons de téléchargement pour les candidats AES
generate_download_buttons <- function(candidate) {
  if(candidate$category == "AES") {
    div(class = "aes-download-buttons",
      downloadButton(
        outputId = paste0("download_program_", candidate$id),
        label = tagList(icon("file-pdf"), " Programme"),
        class = "btn btn-outline-primary btn-sm"
      ),
      downloadButton(
        outputId = paste0("download_bio_", candidate$id),
        label = tagList(icon("file-alt"), " Biographie"),
        class = "btn btn-outline-primary btn-sm"
      )
    )
  } else {
    NULL
  }
}

# Génération des cartes de candidats avec vues multiples
output$candidates_cards <- renderUI({
  candidates <- get_filtered_candidates()
  current_view <- view_mode()
  
  if (nrow(candidates) == 0) {
    return(div(class = "empty-state-content",
      icon("user-slash", class = "empty-icon"),
      h4("Aucun candidat trouvé"),
      p("Essayez de modifier vos critères de recherche ou de filtrage."),
      actionButton("reset_empty_filters", 
        label = tagList(icon("refresh", class = "me-2"), "Réinitialiser les filtres"),
        class = "btn btn-primary")
    ))
  }
  
  if(current_view == "list") {
    # Mode liste horizontal
    list_items <- lapply(1:nrow(candidates), function(i) {
      candidate <- candidates[i, ]
      
      div(class = "candidate-list-item",
        div(class = "candidate-list-content",
          div(class = "candidate-list-avatar",
            img(src = if(is.na(candidate$photo_url) || candidate$photo_url == "") "images/default_candidate.svg" else candidate$photo_url,
                class = "list-avatar", alt = paste("Photo de", candidate$name))
          ),
          div(class = "candidate-list-info",
            div(class = "candidate-list-header",
              h5(candidate$name, class = "candidate-list-name"),
              span(candidate$position_name, class = "candidate-list-position badge")
            ),
            p(if(is.na(candidate$bio) || candidate$bio == "") "Aucune biographie disponible." else candidate$bio,
              class = "candidate-list-bio")
          ),
          div(class = "candidate-list-actions",
            if(candidate$category == "AES") {
              div(class = "aes-download-buttons",
                downloadButton(
                  outputId = paste0("download_program_", candidate$id),
                  label = tagList(icon("file-pdf"), " Programme"),
                  class = "btn btn-outline-primary btn-sm"
                ),
                downloadButton(
                  outputId = paste0("download_bio_", candidate$id),
                  label = tagList(icon("file-alt"), " Biographie"),
                  class = "btn btn-outline-primary btn-sm"
                )
              )
            },
            actionButton(
              inputId = paste0("view_profile_list_", candidate$id),
              label = tagList(icon("user"), " Profil"),
              class = "btn btn-outline-primary btn-sm"
            ),
                      # Vérifier les conditions pour activer/désactiver le bouton de vote
          {
            can_vote <- TRUE
            vote_btn_class <- "btn btn-success btn-sm"
            vote_btn_label <- tagList(icon("vote-yea"), " Voter")
            
            # Vérifier si l'utilisateur est authentifié
            if (is.null(user$authenticated) || !user$authenticated) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("lock"), " Connectez-vous")
              vote_btn_class <- "btn btn-secondary btn-sm"
            }
            # Vérifier si l'utilisateur est un admin
            else if (!is.null(user$year) && user$year == "Administration") {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("ban"), " Admin")
              vote_btn_class <- "btn btn-warning btn-sm"
            }
            # Vérifier si le vote est ouvert
            else if (!is_voting_open()) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("clock"), " Vote fermé")
              vote_btn_class <- "btn btn-secondary btn-sm"
            }
            # Vérifier si déjà voté pour ce poste
            else if (!is.null(user$id)) {
              existing_votes <- dbGetQuery(values$con,
                                           "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                           params = list(user$id, candidate$position_id))
              if(nrow(existing_votes) > 0) {
                can_vote <- FALSE
                vote_btn_label <- tagList(icon("check"), " Déjà voté")
                vote_btn_class <- "btn btn-outline-success btn-sm"
              }
            }
            
            actionButton(
              inputId = paste0("vote_for_list_", candidate$id),
              label = vote_btn_label,
              class = vote_btn_class,
              disabled = if(!can_vote) "disabled" else NULL
            )
          }
          )
        )
      )
    })
    
    div(class = "candidates-list-container", list_items)
    
  } else if(current_view == "card") {
    # Mode cartes détaillées
    card_items <- lapply(1:nrow(candidates), function(i) {
      candidate <- candidates[i, ]
      
      div(class = "candidate-card-detailed",
        div(class = "card-header-detailed",
          img(src = if(is.na(candidate$photo_url) || candidate$photo_url == "") "images/default_candidate.svg" else candidate$photo_url,
              class = "candidate-photo-large", alt = paste("Photo de", candidate$name)),
          div(class = "candidate-overlay",
            h4(candidate$name, class = "candidate-name-large"),
            span(candidate$position_name, class = "candidate-position-large badge")
          )
        ),
        div(class = "card-body-detailed",
          if(candidate$category == "AES") {
            div(class = "aes-download-buttons",
              downloadButton(
                outputId = paste0("download_program_", candidate$id),
                label = tagList(icon("file-pdf"), " Télécharger le programme"),
                class = "btn btn-outline-primary"
              ),
              downloadButton(
                outputId = paste0("download_bio_", candidate$id),
                label = tagList(icon("file-alt"), " Télécharger la biographie"),
                class = "btn btn-outline-primary"
              )
            )
          } else {
            p(if(is.na(candidate$bio) || candidate$bio == "") "Aucune biographie disponible." else candidate$bio,
              class = "candidate-bio-full")
          }
        ),
        div(class = "card-actions-detailed",
          actionButton(
            inputId = paste0("view_profile_card_", candidate$id),
            label = tagList(icon("eye"), " Voir le profil"),
            class = "btn btn-outline-primary"
          ),
          # Vérifier les conditions pour activer/désactiver le bouton de vote
          {
            can_vote <- TRUE
            vote_btn_class <- "btn btn-success"
            vote_btn_label <- tagList(icon("vote-yea"), " Voter")
            
            # Vérifier si l'utilisateur est authentifié
            if (is.null(user$authenticated) || !user$authenticated) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("lock"), " Connectez-vous")
              vote_btn_class <- "btn btn-secondary"
            }
            # Vérifier si l'utilisateur est un admin
            else if (!is.null(user$year) && user$year == "Administration") {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("ban"), " Admin")
              vote_btn_class <- "btn btn-warning"
            }
            # Vérifier si le vote est ouvert
            else if (!is_voting_open()) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("clock"), " Vote fermé")
              vote_btn_class <- "btn btn-secondary"
            }
            # Vérifier si déjà voté pour ce poste
            else if (!is.null(user$id)) {
              existing_votes <- dbGetQuery(values$con,
                                           "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                           params = list(user$id, candidate$position_id))
              if(nrow(existing_votes) > 0) {
                can_vote <- FALSE
                vote_btn_label <- tagList(icon("check"), " Déjà voté")
                vote_btn_class <- "btn btn-outline-success"
              }
            }
            
          actionButton(
            inputId = paste0("vote_for_card_", candidate$id),
              label = vote_btn_label,
              class = vote_btn_class,
              disabled = if(!can_vote) "disabled" else NULL
          )
          }
        )
      )
    })
    
    div(class = "candidates-card-container", card_items)
    
  } else {
    # Mode grille (défaut)
    grid_items <- lapply(1:nrow(candidates), function(i) {
      candidate <- candidates[i, ]
      
      div(class = "candidate-card",
        div(class = "candidate-card-header",
          img(src = if(is.na(candidate$photo_url) || candidate$photo_url == "") "images/default_candidate.svg" else candidate$photo_url,
              class = "candidate-avatar", alt = paste("Photo de", candidate$name)),
          div(class = "candidate-basic-info",
            h5(candidate$name, class = "candidate-name"),
            span(candidate$position_name, class = "candidate-position badge")
          )
        ),
        div(class = "candidate-card-body",
          if(candidate$category == "AES") {
            div(class = "aes-download-buttons",
              downloadButton(
                outputId = paste0("download_program_", candidate$id),
                label = tagList(icon("file-pdf"), " Programme"),
                class = "btn btn-outline-primary btn-sm"
              ),
              downloadButton(
                outputId = paste0("download_bio_", candidate$id),
                label = tagList(icon("file-alt"), " Biographie"),
                class = "btn btn-outline-primary btn-sm"
              )
            )
          } else {
            p(if(is.na(candidate$bio) || candidate$bio == "") "Aucune biographie disponible." else candidate$bio,
              class = "candidate-bio-preview")
          }
        ),
        div(class = "candidate-actions",
          actionButton(
            inputId = paste0("view_profile_", candidate$id),
            label = tagList(icon("user"), " Profil"),
            class = "btn btn-outline-primary btn-sm"
          ),
          # Vérifier les conditions pour activer/désactiver le bouton de vote
          {
            can_vote <- TRUE
            vote_btn_class <- "btn btn-success btn-sm"
            vote_btn_label <- tagList(icon("vote-yea"), " Voter")
            
            # Vérifier si l'utilisateur est authentifié
            if (is.null(user$authenticated) || !user$authenticated) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("lock"), " Connectez-vous")
              vote_btn_class <- "btn btn-secondary btn-sm"
            }
            # Vérifier si l'utilisateur est un admin
            else if (!is.null(user$year) && user$year == "Administration") {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("ban"), " Admin")
              vote_btn_class <- "btn btn-warning btn-sm"
            }
            # Vérifier si le vote est ouvert
            else if (!is_voting_open()) {
              can_vote <- FALSE
              vote_btn_label <- tagList(icon("clock"), " Vote fermé")
              vote_btn_class <- "btn btn-secondary btn-sm"
            }
            # Vérifier si déjà voté pour ce poste
            else if (!is.null(user$id)) {
              existing_votes <- dbGetQuery(values$con,
                                           "SELECT * FROM votes WHERE voter_id = ? AND position_id = ?",
                                           params = list(user$id, candidate$position_id))
              if(nrow(existing_votes) > 0) {
                can_vote <- FALSE
                vote_btn_label <- tagList(icon("check"), " Déjà voté")
                vote_btn_class <- "btn btn-outline-success btn-sm"
              }
            }
            
          actionButton(
            inputId = paste0("vote_for_", candidate$id),
              label = vote_btn_label,
              class = vote_btn_class,
              disabled = if(!can_vote) "disabled" else NULL
          )
          }
        )
      )
    })
    
    div(class = "candidates-grid-container", grid_items)
  }
})

# Observer pour la réinitialisation depuis l'état vide
observeEvent(input$reset_empty_filters, {
  selected_positions_filter(c())
  current_search_term("")
  updateTextInput(session, "candidate_search", value = "")
})

# Gestion des clics sur les profils et votes (pour tous les modes)
observe({
  candidates <- get_filtered_candidates()
  
  if(nrow(candidates) > 0) {
    for(i in 1:nrow(candidates)) {
      candidate_id <- candidates$id[i]
      
      # Profils et votes
      local({
        id <- candidate_id
        
        # Profils - Mode grille
        observeEvent(input[[paste0("view_profile_", id)]], {
          candidate_info <- candidates[candidates$id == id, ]
          showModal(modalDialog(
            title = paste("Profil de", candidate_info$name),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            div(class = "candidate-profile-modal",
              h4("Informations détaillées"),
              p(strong("Poste: "), candidate_info$position_name),
              p(strong("Biographie: "), 
                if(is.na(candidate_info$bio) || candidate_info$bio == "") 
                  "Aucune biographie disponible." 
                else 
                  candidate_info$bio),
              p(strong("Programme: "), 
                if(is.na(candidate_info$program) || candidate_info$program == "") 
                  "Aucun programme disponible." 
                else 
                  candidate_info$program)
            )
          ))
        })
        
        # Profils - Mode liste
        observeEvent(input[[paste0("view_profile_list_", id)]], {
          candidate_info <- candidates[candidates$id == id, ]
          showModal(modalDialog(
            title = paste("Profil de", candidate_info$name),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            div(class = "candidate-profile-modal",
              h4("Informations détaillées"),
              p(strong("Poste: "), candidate_info$position_name),
              p(strong("Biographie: "), 
                if(is.na(candidate_info$bio) || candidate_info$bio == "") 
                  "Aucune biographie disponible." 
                else 
                  candidate_info$bio),
              p(strong("Programme: "), 
                if(is.na(candidate_info$program) || candidate_info$program == "") 
                  "Aucun programme disponible." 
                else 
                  candidate_info$program)
            )
          ))
        })
        
        # Profils - Mode carte
        observeEvent(input[[paste0("view_profile_card_", id)]], {
          candidate_info <- candidates[candidates$id == id, ]
          showModal(modalDialog(
            title = paste("Profil de", candidate_info$name),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            div(class = "candidate-profile-modal",
              h4("Informations détaillées"),
              p(strong("Poste: "), candidate_info$position_name),
              p(strong("Biographie: "), 
                if(is.na(candidate_info$bio) || candidate_info$bio == "") 
                  "Aucune biographie disponible." 
                else 
                  candidate_info$bio),
              p(strong("Programme: "), 
                if(is.na(candidate_info$program) || candidate_info$program == "") 
                  "Aucun programme disponible." 
                else 
                  candidate_info$program)
            )
          ))
    })
        
        # Votes - Mode grille
        observeEvent(input[[paste0("vote_for_", id)]], {
          handle_candidate_vote(id)
        })
        
        # Votes - Mode liste
        observeEvent(input[[paste0("vote_for_list_", id)]], {
          handle_candidate_vote(id)
        })
        
        # Votes - Mode carte
        observeEvent(input[[paste0("vote_for_card_", id)]], {
          handle_candidate_vote(id)
        })
  })
    }
  }
})

# Fonction pour gérer le vote d'un candidat
handle_candidate_vote <- function(candidate_id) {
  # Log de débogage
  cat("handle_candidate_vote appelée avec candidate_id:", candidate_id, "\n")
  cat("user$authenticated:", user$authenticated, "\n")
  cat("user$id:", user$id, "\n")
  
  # Vérifier si l'utilisateur est authentifié
  if (is.null(user$authenticated) || !user$authenticated) {
    showNotification("Vous devez être connecté pour voter.", type = "error")
    return()
  }
  
  # Vérifier si l'ID utilisateur est présent
  if (is.null(user$id) || user$id == "") {
    showNotification("Erreur: Identifiant utilisateur manquant.", type = "error")
    return()
  }
  
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
  
  # Valider l'ID du candidat
  if (is.null(candidate_id) || is.na(candidate_id)) {
    showNotification("Erreur: Identifiant candidat invalide.", type = "error")
    return()
  }
  
  # Récupérer les informations du candidat avec gestion d'erreur
  candidate_info <- tryCatch({
    dbGetQuery(values$con, 
      "SELECT c.*, p.name as position_name FROM candidates c 
       JOIN positions p ON c.position_id = p.id 
       WHERE c.id = ?", 
      params = list(as.integer(candidate_id)))
  }, error = function(e) {
    cat("Erreur lors de la récupération du candidat:", e$message, "\n")
    return(data.frame())
  })
  
  if(nrow(candidate_info) == 0) {
    showNotification("Candidat introuvable.", type = "error")
    return()
  }
  
  position_id <- candidate_info$position_id[1]
  
  # Log des informations récupérées
  cat("Candidat trouvé:", candidate_info$name[1], "\n")
  cat("Position ID:", position_id, "\n")
  
  # Vérifier si l'utilisateur a déjà voté pour ce poste
  existing_votes <- tryCatch({
    dbGetQuery(values$con,
               "SELECT COUNT(*) as count FROM votes WHERE voter_id = ? AND position_id = ?",
               params = list(as.character(user$id), as.integer(position_id)))
  }, error = function(e) {
    cat("Erreur lors de la vérification des votes existants:", e$message, "\n")
    return(data.frame(count = 0))
  })
  
  if(existing_votes$count > 0) {
    showNotification("Vous avez déjà voté pour ce poste.", type = "error")
    return()
  }
  
  # Confirmation avant vote
  showModal(modalDialog(
    title = "Confirmation de vote",
    div(class = "text-center",
      h4(paste("Voter pour", candidate_info$name[1])),
      p(paste("Poste:", candidate_info$position_name[1])),
      br(),
      p("Êtes-vous sûr de vouloir voter pour ce candidat?"),
      p(strong("Ce vote est définitif et ne pourra pas être modifié."))
    ),
    footer = tagList(
      modalButton("Annuler"),
      actionButton("confirm_candidate_vote", "Confirmer mon vote", class = "btn-success")
    )
  ))
  
  # Stocker temporairement les informations de vote
  user$temp_vote <- list(
    candidate_id = as.integer(candidate_id),
    position_id = as.integer(position_id),
    candidate_name = candidate_info$name[1],
    position_name = candidate_info$position_name[1]
  )
  
  cat("Données temporaires stockées:", toString(user$temp_vote), "\n")
}

# Observer pour la confirmation du vote depuis la page candidats
observeEvent(input$confirm_candidate_vote, {
  if (!is.null(user$temp_vote)) {
    # Vérifier que toutes les données sont présentes
    if (is.null(user$id) || is.null(user$temp_vote$candidate_id) || is.null(user$temp_vote$position_id)) {
      showNotification("Erreur: Données de vote incomplètes.", type = "error")
      return()
    }
    
    # S'assurer que les types sont corrects
    voter_id <- as.character(user$id)
    candidate_id <- as.integer(user$temp_vote$candidate_id)
    position_id <- as.integer(user$temp_vote$position_id)
    
    # Vérifier que la conversion a réussi
    if (is.na(candidate_id) || is.na(position_id)) {
      showNotification("Erreur: Identifiants invalides.", type = "error")
      return()
    }
    
    # Enregistrer le vote
    vote_hash <- digest::digest(paste(voter_id, candidate_id, position_id, Sys.time()), algo = "sha256")
    
    tryCatch({
      # Vérifier que la connexion est active
      if (is.null(values$con) || !dbIsValid(values$con)) {
        showNotification("Erreur: Problème de connexion à la base de données.", type = "error")
        return()
      }
      
      # Activer les contraintes de clés étrangères (important pour SQLite)
      dbExecute(values$con, "PRAGMA foreign_keys = ON")
      
      # Vérifier que le candidat existe toujours
      candidate_check <- dbGetQuery(values$con,
                                    "SELECT COUNT(*) as count FROM candidates WHERE id = ?",
                                    params = list(candidate_id))
      
      if (candidate_check$count == 0) {
        showNotification("Erreur: Le candidat sélectionné n'existe plus.", type = "error")
        user$temp_vote <- NULL
        removeModal()
        return()
      }
      
      # Vérifier que le poste existe
      position_check <- dbGetQuery(values$con,
                                   "SELECT COUNT(*) as count FROM positions WHERE id = ?",
                                   params = list(position_id))
      
      if (position_check$count == 0) {
        showNotification("Erreur: Le poste sélectionné n'existe plus.", type = "error")
        user$temp_vote <- NULL
        removeModal()
        return()
      }
      
      # Vérifier que l'électeur existe
      voter_check <- dbGetQuery(values$con,
                                "SELECT COUNT(*) as count FROM voters WHERE id = ?",
                                params = list(voter_id))
      
      if (voter_check$count == 0) {
        showNotification("Erreur: Votre profil d'électeur n'a pas été trouvé.", type = "error")
        user$temp_vote <- NULL
        removeModal()
        return()
      }
      
      # Vérifier si l'utilisateur n'a pas déjà voté pour ce poste (double vérification)
      existing_votes <- dbGetQuery(values$con,
                                   "SELECT COUNT(*) as count FROM votes WHERE voter_id = ? AND position_id = ?",
                                   params = list(voter_id, position_id))
      
      if (existing_votes$count > 0) {
        showNotification("Erreur: Vous avez déjà voté pour ce poste.", type = "error")
        user$temp_vote <- NULL
        removeModal()
        return()
      }
      
      # Vérifier l'unicité du hash (éviter les doublons)
      hash_check <- dbGetQuery(values$con,
                               "SELECT COUNT(*) as count FROM votes WHERE hash = ?",
                               params = list(vote_hash))
      
      if (hash_check$count > 0) {
        # Régénérer un nouveau hash
        vote_hash <- digest::digest(paste(voter_id, candidate_id, position_id, Sys.time(), runif(1)), algo = "sha256")
      }
      
      # Commencer une transaction pour garantir la cohérence
      dbExecute(values$con, "BEGIN TRANSACTION")
      
      # Insérer le vote
      dbExecute(values$con, 
        "INSERT INTO votes (voter_id, candidate_id, position_id, hash) VALUES (?, ?, ?, ?)",
        params = list(voter_id, candidate_id, position_id, vote_hash)
      )
      
      # Mettre à jour seulement le timestamp du vote
      # Note: has_voted sera mis à jour seulement quand l'électeur aura voté pour tous les postes requis
      dbExecute(values$con,
        "UPDATE voters SET vote_timestamp = CURRENT_TIMESTAMP WHERE id = ?",
        params = list(voter_id))
      
      # Valider la transaction
      dbExecute(values$con, "COMMIT")
      
      showNotification("Vote enregistré avec succès!", type = "message")
      
      # Nettoyer les données temporaires
      user$temp_vote <- NULL
      
      # Fermer la modal
      removeModal()
      
    }, error = function(e) {
      # Annuler la transaction en cas d'erreur
      tryCatch({
        dbExecute(values$con, "ROLLBACK")
      }, error = function(rollback_error) {
        cat("Erreur lors du rollback:", rollback_error$message, "\n")
      })
      
      # Afficher l'erreur détaillée dans la console
      cat("Erreur lors de l'enregistrement du vote:\n")
      cat("Message d'erreur:", e$message, "\n")
      cat("voter_id:", voter_id, "\n")
      cat("candidate_id:", candidate_id, "\n")
      cat("position_id:", position_id, "\n")
      cat("vote_hash:", vote_hash, "\n")
      
      # Nettoyer les données temporaires
      user$temp_vote <- NULL
      
      # Fermer la modal
      removeModal()
      
      # Afficher une notification avec plus de détails
      error_msg <- paste("Erreur lors de l'enregistrement du vote:", e$message)
      showNotification(error_msg, type = "error", duration = 10)
    })
  }
})

# Gestionnaires de téléchargement pour les programmes et biographies
lapply(1:100, function(i) {  # On suppose un maximum de 100 candidats
  # Programme
  output[[paste0("download_program_", i)]] <- downloadHandler(
    filename = function() {
      candidate <- dbGetQuery(values$con, "SELECT name FROM candidates WHERE id = ?", params = list(i))
      if(nrow(candidate) > 0) {
        paste0("Programme_", gsub(" ", "_", candidate$name), ".pdf")
      } else {
        "programme.pdf"
      }
    },
    content = function(file) {
      # Ici, vous devrez implémenter la logique pour récupérer le fichier PDF
      # Par exemple, depuis un dossier "programs" dans www/
      program_path <- file.path("www", "programs", paste0("program_", i, ".pdf"))
      if(file.exists(program_path)) {
        file.copy(program_path, file)
      } else {
        # Créer un PDF vide si le fichier n'existe pas
        pdf(file)
        plot.new()
        text(0.5, 0.5, "Programme non disponible", cex = 1.5)
        dev.off()
      }
    }
  )
  
  # Biographie
  output[[paste0("download_bio_", i)]] <- downloadHandler(
    filename = function() {
      candidate <- dbGetQuery(values$con, "SELECT name FROM candidates WHERE id = ?", params = list(i))
      if(nrow(candidate) > 0) {
        paste0("Biographie_", gsub(" ", "_", candidate$name), ".pdf")
      } else {
        "biographie.pdf"
      }
    },
    content = function(file) {
      # Ici, vous devrez implémenter la logique pour récupérer le fichier PDF
      # Par exemple, depuis un dossier "bios" dans www/
      bio_path <- file.path("www", "bios", paste0("bio_", i, ".pdf"))
      if(file.exists(bio_path)) {
        file.copy(bio_path, file)
      } else {
        # Créer un PDF vide si le fichier n'existe pas
        pdf(file)
        plot.new()
        text(0.5, 0.5, "Biographie non disponible", cex = 1.5)
        dev.off()
      }
    }
  )
}) 
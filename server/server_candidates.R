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
            actionButton(
              inputId = paste0("vote_for_list_", candidate$id),
              label = tagList(icon("vote-yea"), " Voter"),
              class = "btn btn-success btn-sm"
            )
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
          actionButton(
            inputId = paste0("vote_for_card_", candidate$id),
            label = tagList(icon("vote-yea"), " Voter"),
            class = "btn btn-success"
          )
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
          actionButton(
            inputId = paste0("vote_for_", candidate$id),
            label = tagList(icon("vote-yea"), " Voter"),
            class = "btn btn-success btn-sm"
          )
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
      
      # Profils
      local({
        id <- candidate_id
        observeEvent(input[[paste0("view_profile_", id)]], {
          # Logique pour afficher le profil
          showModal(modalDialog(
            title = paste("Profil de", candidates[candidates$id == id, "name"]),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            # Contenu du profil
            div(class = "candidate-profile-modal",
              # Contenu détaillé du candidat
              h4("Informations détaillées à venir...")
            )
          ))
        })
        
        observeEvent(input[[paste0("view_profile_list_", id)]], {
          # Même logique pour le mode liste
          showModal(modalDialog(
            title = paste("Profil de", candidates[candidates$id == id, "name"]),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            div(class = "candidate-profile-modal",
              h4("Informations détaillées à venir...")
            )
          ))
        })
        
        observeEvent(input[[paste0("view_profile_card_", id)]], {
          # Même logique pour le mode carte
          showModal(modalDialog(
            title = paste("Profil de", candidates[candidates$id == id, "name"]),
            size = "l",
            easyClose = TRUE,
            footer = modalButton("Fermer"),
            div(class = "candidate-profile-modal",
              h4("Informations détaillées à venir...")
            )
          ))
    })
  })
    }
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
# server/server_results.R - Gestion des résultats et procès-verbaux

# Vérifier si des votes existent
has_votes <- reactive({
  tryCatch({
    vote_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM votes")$count
    return(vote_count > 0)
  }, error = function(e) {
    return(FALSE)
  })
})

# Variable réactive pour stocker les postes sélectionnés
selected_result_positions <- reactiveVal(c())

# Génération des cases à cocher avec icônes pour chaque poste
output$result_position_checkboxes <- renderUI({
  # Récupérer tous les postes
  positions <- dbGetQuery(values$con, "SELECT id, name FROM positions ORDER BY name")
  
  # Associer une icône à chaque type de poste
  position_icons <- list(
    "Président" = "crown",
    "Secrétaire" = "file-alt",
    "Conseiller" = "briefcase",
    "Chargé" = "bullhorn",
    "Club" = "users"
  )
  
  # Si aucun vote n'a été enregistré
  if(!has_votes()) {
    return(div(
      style = "background: transparent; border-left: 4px solid #3f51b5; color: #303f9f; border-radius: 10px; padding: 15px; margin-bottom: 20px; box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);",
      icon("info-circle", class = "me-2 text-primary"),
      "Aucun vote n'a encore été enregistré. Les résultats seront disponibles après la clôture des votes."
    ))
  }
  
  # Créer les cases à cocher pour chaque poste
  position_checkboxes <- lapply(1:nrow(positions), function(i) {
    position_id <- positions$id[i]
    position_name <- positions$name[i]
    
    # Vérifier s'il y a des votes pour ce poste
    vote_count <- dbGetQuery(values$con, 
      "SELECT COUNT(*) as count FROM votes WHERE position_id = ?", 
      params = list(position_id))$count
    
    # Ne pas afficher ce poste s'il n'y a pas de votes
    if(vote_count == 0) {
      return(NULL)
    }
    
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
    
    is_selected <- as.character(position_id) %in% selected_result_positions()
    
    div(class = "position-filter-item mb-2",
      div(class = paste0("form-check d-flex align-items-center", if(is_selected) " active-filter" else ""),
        tags$input(type = "checkbox", id = paste0("result_filter_", position_id), 
                  class = "form-check-input me-2 position-checkbox",
                  `data-position-id` = position_id,
                  checked = is_selected,
                  onclick = sprintf("Shiny.setInputValue('result_position_clicked', {id: %s, value: this.checked, random: Math.random()})", position_id)),
        tags$label(`for` = paste0("result_filter_", position_id), 
                  class = "form-check-label d-flex align-items-center",
                  icon(icon_name, class = "me-2 text-danger"), 
                  position_name)
      )
    )
  })
  
  # Supprimer les éléments NULL (postes sans votes)
  position_checkboxes <- position_checkboxes[!sapply(position_checkboxes, is.null)]
  
  # Si aucun poste n'a de votes
  if(length(position_checkboxes) == 0) {
    return(div(
      class = "alert alert-info",
      icon("info-circle", class = "me-2"),
      "Aucun vote n'a encore été enregistré pour les postes disponibles."
    ))
  }
  
  # Combiner tous les éléments
  tagList(
    div(class = "filter-header mb-3",
        div(class = "d-flex align-items-center", 
            icon("filter", class = "me-2 text-danger"),
            h4("Filtrer par poste", class = "mb-0")
        )
    ),
    div(class = "position-filters mb-4",
        position_checkboxes
    ),
    div(class = "d-flex justify-content-end mt-4",
      actionButton("reset_result_filters", "Réinitialiser les filtres", 
                class = "btn btn-sm btn-outline-secondary",
                icon = icon("sync"))
    )
  )
})

# Gestion du clic sur un poste spécifique pour les résultats
observeEvent(input$result_position_clicked, {
  position_id <- as.character(input$result_position_clicked$id)
  is_checked <- input$result_position_clicked$value
  
  current_selected <- selected_result_positions()
  
  if (is_checked) {
    # Ajouter le poste sélectionné
    current_selected <- c(current_selected, position_id)
  } else {
    # Retirer le poste désélectionné
    current_selected <- setdiff(current_selected, position_id)
  }
  
  # Mettre à jour les positions sélectionnées
  selected_result_positions(current_selected)
})

# Réinitialisation des filtres résultats
observeEvent(input$reset_result_filters, {
  selected_result_positions(c())
})

# Graphique des résultats
output$results_chart <- renderPlot({
  # Vérifier s'il y a des votes
  if(!has_votes()) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a encore été enregistré.\nLes résultats seront disponibles après la clôture des votes.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Vérifier si des postes sont sélectionnés
  selected_positions <- selected_result_positions()
  if(length(selected_positions) == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Veuillez sélectionner au moins un poste pour afficher les résultats.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Récupérer tous les résultats pour les postes sélectionnés
  # Construire la requête SQL avec la bonne quantité de paramètres
  position_placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
  
  votes_data <- tryCatch({
    # Récupérer les votes par candidat
    dbGetQuery(values$con, sprintf("
      SELECT 
        c.name as candidate_name, 
        p.name as position_name,
        COUNT(*) as vote_count
      FROM 
        votes v
      JOIN 
        candidates c ON v.candidate_id = c.id
      JOIN 
        positions p ON c.position_id = p.id
      WHERE 
        c.position_id IN (%s)
      GROUP BY 
        c.id
      ORDER BY 
        p.name, vote_count DESC
      ", position_placeholders),
      params = as.list(selected_positions)
    )
  }, error = function(e) {
    return(data.frame())
  })
  
  # Vérifier si des résultats ont été trouvés
  if(nrow(votes_data) == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a été enregistré pour les postes sélectionnés.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Créer une colonne combinée pour la légende
  votes_data$label <- paste0(votes_data$candidate_name, " (", votes_data$position_name, ")")
  
  # Création du graphique
  ggplot(votes_data, aes(x = reorder(label, -vote_count), y = vote_count, fill = position_name)) +
    geom_col() +
    geom_text(aes(label = vote_count), vjust = -0.5) +
    scale_fill_brewer(palette = "Set1") +
    labs(
      title = "Résultats des élections",
      x = NULL,
      y = "Nombre de votes",
      fill = "Poste"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
})

# Détails des résultats
output$results_details <- renderUI({
  # Vérifier s'il y a des votes
  if(!has_votes()) {
    return(div(
      style = "background: transparent; border-left: 4px solid #3f51b5; color: #303f9f; border-radius: 10px; padding: 15px; margin-bottom: 20px; box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);",
      icon("info-circle", class = "me-2 text-primary"),
      "Aucun vote n'a encore été enregistré. Les détails des résultats seront disponibles après la clôture des votes."))
  }
  
  # Vérifier si des postes sont sélectionnés
  selected_positions <- selected_result_positions()
  if(length(selected_positions) == 0) {
    return(div(class = "alert alert-info", 
              icon("info-circle", class = "me-2"),
              "Veuillez sélectionner au moins un poste pour afficher les détails des résultats."))
  }
  
  # Récupérer tous les résultats pour les postes sélectionnés
  position_placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
  
  votes_data <- tryCatch({
    # Récupérer les votes par candidat et par poste
    dbGetQuery(values$con, sprintf("
      SELECT 
        c.name as candidate_name, 
        p.name as position_name,
        p.id as position_id,
        COUNT(*) as vote_count
      FROM 
        votes v
      JOIN 
        candidates c ON v.candidate_id = c.id
      JOIN 
        positions p ON c.position_id = p.id
      WHERE 
        c.position_id IN (%s)
      GROUP BY 
        c.id
      ORDER BY 
        p.name, vote_count DESC
      ", position_placeholders),
      params = as.list(selected_positions)
    )
  }, error = function(e) {
    return(data.frame())
  })
  
  # Vérifier si des résultats ont été trouvés
  if(nrow(votes_data) == 0) {
    return(div(class = "alert alert-info", 
              icon("info-circle", class = "me-2"),
              "Aucun vote n'a été enregistré pour les postes sélectionnés."))
  }
  
  # Obtenir la liste des postes sélectionnés qui ont des votes
  unique_positions <- unique(votes_data[, c("position_id", "position_name")])
  
  # Créer des tableaux pour chaque poste
  position_tables <- lapply(1:nrow(unique_positions), function(i) {
    position_id <- unique_positions$position_id[i]
    position_name <- unique_positions$position_name[i]
    
    # Filtrer les données pour ce poste
    position_votes <- votes_data[votes_data$position_id == position_id, ]
    
    # Calculer le total des votes pour ce poste
    total_votes <- sum(position_votes$vote_count)
    
    # Calculer les pourcentages
    position_votes$percent <- round(position_votes$vote_count / total_votes * 100, 1)
    
    # Trouver le vainqueur
    winner <- position_votes[which.max(position_votes$vote_count), ]
    
    div(class = "position-section",
        h4(class = "position-header", 
           icon("award", class = "me-2"),
           position_name
        ),
        div(class = "position-content",
            div(class = "row",
                div(class = "col-md-8",
                    tags$table(class = "table table-striped table-hover",
                              tags$thead(
                                tags$tr(
                                  tags$th("Candidat"),
                                  tags$th("Votes"),
                                  tags$th("Pourcentage")
                                )
                              ),
                              tags$tbody(
                                lapply(1:nrow(position_votes), function(j) {
                                  is_winner <- j == 1  # Le premier est le gagnant (trié par vote_count DESC)
                                  tags$tr(
                                    class = if(is_winner) "table-success" else "",
                                    tags$td(
                                      div(class = "d-flex align-items-center",
                                        if(is_winner) span(class = "me-2", icon("check-circle", class = "text-success")) else NULL,
                                        div(
                                          strong(position_votes$candidate_name[j]), 
                                          if(is_winner) span(class = "badge bg-success ms-2", "Élu") else NULL
                                        )
                                      )
                                    ),
                                    tags$td(
                                      div(class = "d-flex align-items-center",
                                        span(class = "me-2", position_votes$vote_count[j]),
                                        div(class = "progress flex-grow-1", style = "height: 6px;",
                                          div(class = "progress-bar", 
                                              role = "progressbar", 
                                              style = sprintf("width: %s%%; background-color: %s;", 
                                                              position_votes$percent[j],
                                                              if(is_winner) "#198754" else "#0d6efd"),
                                              `aria-valuenow` = position_votes$percent[j], 
                                              `aria-valuemin` = "0", 
                                              `aria-valuemax` = "100")
                                        )
                                      )
                                    ),
                                    tags$td(
                                      strong(paste0(position_votes$percent[j], "%"))
                                    )
                                  )
                                })
                              )
                    )
                ),
                div(class = "col-md-4",
                    div(class = "winner-info",
                        h5(icon("trophy", class = "me-2 text-warning"), 
                           "Résultat final"),
                        div(class = "mt-3",
                            div(class = "mb-2", icon("users", class = "me-2 text-info"), 
                                strong("Votes exprimés: "), 
                                span(total_votes, class = "badge bg-info text-white")
                            ),
                            div(class = "mb-2", icon("medal", class = "me-2 text-success"), 
                                strong("Candidat élu: "), 
                                span(winner$candidate_name, class = "fw-bold")
                            ),
                            div(class = "mb-2", icon("chart-simple", class = "me-2 text-primary"), 
                                strong("Score: "), 
                                span(paste0(winner$vote_count, " voix (", winner$percent, "%)"))
                            )
                        )
                    )
                )
            )
        )
    )
  })
  
  # Combiner tous les tableaux
  div(
    class = "results-details mt-4",
    div(class = "alert alert-success mb-4 d-flex align-items-center",
        div(class = "me-3", 
            icon("circle-check", class = "fa-2x")
        ),
        div(
            h4(class = "mb-1", "Résultats officiels"),
            p(class = "mb-0", "Voici les résultats détaillés des élections")
        )
    ),
    position_tables,
    div(class = "text-end text-muted small mt-4",
        icon("clock", class = "me-1"),
        "Résultats générés le ", format(Sys.time(), "%d/%m/%Y à %H:%M")
    )
  )
})

# Téléchargement du procès-verbal
output$downloadPV <- downloadHandler(
  filename = function() {
    # Si plusieurs postes sont sélectionnés, utiliser un nom générique
    selected_positions <- selected_result_positions()
    if(length(selected_positions) > 1) {
      return(paste0("PV-elections-multiples-", Sys.Date(), ".pdf"))
    } else if(length(selected_positions) == 1) {
      # Récupérer le nom du poste sélectionné
      position_name <- dbGetQuery(values$con, 
        "SELECT name FROM positions WHERE id = ?", 
        params = list(selected_positions[1]))$name
      
      sanitized_name <- gsub("[^a-zA-Z0-9]", "-", position_name)
      return(paste0("PV-election-", sanitized_name, "-", Sys.Date(), ".pdf"))
    } else {
      return(paste0("PV-elections-", Sys.Date(), ".pdf"))
    }
  },
  content = function(file) {
    # S'assurer que les packages nécessaires sont disponibles
    req(requireNamespace("rmarkdown", quietly = TRUE))
    req(requireNamespace("knitr", quietly = TRUE))
    
    # Vérifier s'il y a des votes
    if(!has_votes()) {
      # Créer un rapport simple indiquant qu'aucun vote n'a été enregistré
      tempReport <- file.path(tempdir(), "pv-election.Rmd")
      
      cat(file = tempReport, "---
title: \"Procès-verbal d'élection\"
date: \"", format(Sys.Date(), '%d/%m/%Y'), "\"
output: pdf_document
---

## Aucun résultat disponible

Aucun vote n'a encore été enregistré dans le système. Le procès-verbal officiel sera disponible après la clôture des votes.

", sep = "")
      
      # Générer le PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
      return()
    }
    
    # Vérifier si des postes sont sélectionnés
    selected_positions <- selected_result_positions()
    if(length(selected_positions) == 0) {
      # Créer un rapport indiquant qu'aucun poste n'est sélectionné
      tempReport <- file.path(tempdir(), "pv-election.Rmd")
      
      cat(file = tempReport, "---
title: \"Procès-verbal d'élection\"
date: \"", format(Sys.Date(), '%d/%m/%Y'), "\"
output: pdf_document
---

## Aucun poste sélectionné

Veuillez sélectionner au moins un poste pour générer un procès-verbal.

", sep = "")
      
      # Générer le PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
      return()
    }
    
    # Récupérer les résultats pour tous les postes sélectionnés
    position_placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
    
    votes_data <- tryCatch({
      dbGetQuery(values$con, sprintf("
        SELECT 
          c.name as candidate_name, 
          p.name as position_name,
          p.id as position_id,
          COUNT(*) as vote_count
        FROM 
          votes v
        JOIN 
          candidates c ON v.candidate_id = c.id
        JOIN 
          positions p ON c.position_id = p.id
        WHERE 
          c.position_id IN (%s)
        GROUP BY 
          c.id
        ORDER BY 
          p.name, vote_count DESC
        ", position_placeholders),
        params = as.list(selected_positions)
      )
    }, error = function(e) {
      return(data.frame())
    })
    
    # Vérifier si des résultats ont été trouvés
    if(nrow(votes_data) == 0) {
      # Créer un rapport indiquant qu'aucun vote n'a été trouvé
      tempReport <- file.path(tempdir(), "pv-election.Rmd")
      
      cat(file = tempReport, "---
title: \"Procès-verbal d'élection\"
date: \"", format(Sys.Date(), '%d/%m/%Y'), "\"
output: pdf_document
---

## Aucun vote enregistré

Aucun vote n'a été enregistré pour les postes sélectionnés.

", sep = "")
      
      # Générer le PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
      return()
    }
    
    # Obtenir la liste des postes qui ont des votes
    unique_positions <- unique(votes_data[, c("position_id", "position_name")])
    
    # Création d'un document Rmarkdown temporaire
    tempReport <- file.path(tempdir(), "pv-election.Rmd")
    
    # Construire le contenu du document
    content <- paste0("---
title: \"Procès-verbal d'élection\"
date: \"", format(Sys.Date(), '%d/%m/%Y'), "\"
output: pdf_document
---

")
    
    # Ajouter une section pour chaque poste
    for (i in 1:nrow(unique_positions)) {
      position_id <- unique_positions$position_id[i]
      position_name <- unique_positions$position_name[i]
      
      # Filtrer les données pour ce poste
      position_votes <- votes_data[votes_data$position_id == position_id, ]
      
      # Calculer le total des votes pour ce poste
      total_votes <- sum(position_votes$vote_count)
      
      # Calculer les pourcentages
      position_votes$percent <- round(position_votes$vote_count / total_votes * 100, 1)
      
      # Trouver le vainqueur
      winner <- position_votes[which.max(position_votes$vote_count), ]
      
      content <- paste0(content, "
## Élection: ", position_name, "
### Date du scrutin: ", format(Sys.Date(), '%d/%m/%Y'), "

Total des votes exprimés: **", total_votes, "**

```{r echo=FALSE, message=FALSE, warning=FALSE}
library(knitr)
df", i, " <- data.frame(
  Candidat = c('", paste(position_votes$candidate_name, collapse = "', '"), "'),
  Voix = c(", paste(position_votes$vote_count, collapse = ", "), "),
  Pourcentage = c('", paste(paste0(position_votes$percent, "%"), collapse = "', '"), "')
)
kable(df", i, ")
```

### Candidat élu

**", winner$candidate_name, "** avec **", winner$vote_count, "** voix, 
soit **", winner$percent, "%** des suffrages exprimés.

")
    }
    
    # Ajouter la section signatures
    content <- paste0(content, "
## Signatures

Fait à _________________, le ", format(Sys.Date(), '%d/%m/%Y'), "

Président du bureau: ________________________

Assesseurs: 
________________________

________________________
")
    
    # Écrire le contenu dans le fichier temporaire
    writeLines(text = content, con = tempReport)
    
    # Essayer de générer le PDF avec gestion des erreurs
    tryCatch({
      # Générer le PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
    }, error = function(e) {
      # Afficher une erreur dans la console pour le débogage
      message("Erreur lors de la génération du PDF: ", e$message)
      # Créer un fichier texte d'urgence avec les informations
      writeLines(sprintf("Erreur de génération du PDF: %s\nVeuillez vérifier que tous les packages nécessaires sont installés.", e$message), file)
    })
  }
) 
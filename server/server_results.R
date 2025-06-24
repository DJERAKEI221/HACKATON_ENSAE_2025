# server/server_results.R - Gestion des résultats et procès-verbaux

# Installation et chargement des packages nécessaires
if (!require("ggforce")) {
  install.packages("ggforce")
}
if (!require("gridExtra")) {
  install.packages("gridExtra")
}
library(ggforce)
library(gridExtra)

# Fonction pour formater les noms longs avec retour à la ligne
format_long_name <- function(name, max_length = 15) {
  # Si le nom est court, le retourner tel quel
  if (nchar(name) <= max_length) {
    return(name)
  }
  
  # Diviser le nom en mots
  words <- strsplit(name, " ")[[1]]
  
  # Si un seul mot, le tronquer
  if (length(words) == 1) {
    return(paste0(substr(name, 1, max_length), "..."))
  }
  
  # Essayer de diviser le nom en deux lignes
  first_line <- ""
  second_line <- ""
  current_line <- 1
  
  for (word in words) {
    if (current_line == 1) {
      if (nchar(first_line) + nchar(word) + 1 <= max_length) {
        first_line <- if (first_line == "") word else paste(first_line, word)
      } else {
        current_line <- 2
        second_line <- word
      }
    } else {
      if (nchar(second_line) + nchar(word) + 1 <= max_length) {
        second_line <- paste(second_line, word)
      } else {
        second_line <- paste0(second_line, "...")
        break
      }
    }
  }
  
  return(paste0(first_line, "\n", second_line))
}

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
  position_placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
  
  votes_data <- tryCatch({
    dbGetQuery(values$con, sprintf("
      SELECT 
        c.name as candidate_name, 
        p.name as position_name,
        p.order_priority,
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
        c.id, p.order_priority
      ORDER BY 
        p.order_priority, vote_count DESC
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
  
  # Calculer le pourcentage de voix pour chaque candidat par poste
  votes_data$percent <- ave(votes_data$vote_count, votes_data$position_name, FUN = function(x) round(100 * x / sum(x), 1))
  
  # Créer un graphique pour chaque poste
  plot_list <- lapply(unique(votes_data$position_name), function(pos) {
    pos_data <- votes_data[votes_data$position_name == pos, ]
    
    # Formater les noms des candidats
    pos_data$display_name <- sapply(pos_data$candidate_name, format_long_name)
    
    ggplot(pos_data, aes(x0 = 0, y0 = 0, r0 = 0.5, r = 1, amount = vote_count, fill = candidate_name)) +
      ggforce::geom_arc_bar(stat = "pie", color = "white", size = 0.5, start = 0, end = pi) +
      geom_text(data = pos_data %>% 
                  mutate(angle = cumsum(vote_count) - vote_count/2,
                         angle = angle/sum(vote_count) * 180,
                         angle = angle * pi/180,
                         x = 1.2 * cos(angle),
                         y = 1.2 * sin(angle)),
                aes(x = x, y = y, label = paste0(display_name, "\n", vote_count, " (", percent, "%)")),
                size = 3, fontface = "bold", color = "#000000") +
      coord_fixed() +
      scale_fill_manual(values = c(
        "#4E79A7",  # Bleu clair
        "#F28E2B",  # Orange
        "#E15759",  # Rouge
        "#76B7B2",  # Turquoise
        "#59A14F",  # Vert
        "#EDC948",  # Jaune
        "#B07AA1",  # Violet
        "#FF9DA7",  # Rose
        "#9C755F",  # Marron
        "#BAB0AC"   # Gris
      )) +
      labs(
        title = pos,
        fill = NULL
      ) +
      theme_void() +
      theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 10), color = "#000000"),
        legend.position = "none",
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA)
      )
  })
  
  # Calculer le nombre de colonnes optimal (max 3 colonnes)
  n_cols <- min(3, length(plot_list))
  
  # Arranger les graphiques en grille
  grid.arrange(grobs = plot_list, ncol = n_cols)
})

# Téléchargement du procès-verbal
output$downloadPV <- downloadHandler(
  filename = function() {
    # Si plusieurs postes sont sélectionnés, utiliser un nom générique
    selected_positions <- selected_result_positions()
    if(length(selected_positions) > 1) {
      return(paste0("PV-elections-multiples-", Sys.Date(), ".html"))
    } else if(length(selected_positions) == 1) {
      # Récupérer le nom du poste sélectionné
      position_name <- tryCatch({
        dbGetQuery(values$con, 
          "SELECT name FROM positions WHERE id = ?", 
          params = list(selected_positions[1]))$name
      }, error = function(e) "position")
      
      sanitized_name <- gsub("[^a-zA-Z0-9]", "-", position_name)
      return(paste0("PV-election-", sanitized_name, "-", Sys.Date(), ".html"))
    } else {
      return(paste0("PV-elections-", Sys.Date(), ".html"))
    }
  },
  content = function(file) {
    tryCatch({
      # Vérifier s'il y a des votes
      if(!has_votes()) {
        html_content <- generate_no_votes_html()
        writeLines(html_content, file)
        return()
      }
      
      # Vérifier si des postes sont sélectionnés
      selected_positions <- selected_result_positions()
      if(length(selected_positions) == 0) {
        # Si aucun poste n'est sélectionné, inclure tous les postes qui ont des votes
        all_positions_with_votes <- tryCatch({
          dbGetQuery(values$con, "
            SELECT DISTINCT p.id 
            FROM positions p 
            JOIN candidates c ON p.id = c.position_id 
            JOIN votes v ON c.id = v.candidate_id
          ")
        }, error = function(e) data.frame(id = integer(0)))
        
        if(nrow(all_positions_with_votes) > 0) {
          selected_positions <- all_positions_with_votes$id
        } else {
          html_content <- generate_no_votes_html()
          writeLines(html_content, file)
          return()
        }
      }
      
      # Récupérer les résultats pour tous les postes sélectionnés
      votes_data <- get_votes_data(selected_positions)
      
      # Vérifier si des résultats ont été trouvés
      if(nrow(votes_data) == 0) {
        html_content <- generate_no_results_html()
        writeLines(html_content, file)
        return()
      }
      
      # Générer le HTML du procès-verbal
      html_content <- generate_pv_html(votes_data)
      writeLines(html_content, file)
      
    }, error = function(e) {
      # En cas d'erreur, créer un document d'erreur simple
      error_html <- paste0("
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset='UTF-8'>
          <title>Erreur - Procès-verbal</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f8f9fa; }
            .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .error { color: #dc3545; border: 1px solid #dc3545; padding: 15px; border-radius: 5px; background-color: #f8d7da; }
          </style>
        </head>
        <body>
          <div class='container'>
            <h1>Erreur lors de la génération du procès-verbal</h1>
            <div class='error'>
              <strong>Erreur:</strong> ", e$message, "<br>
              <strong>Date:</strong> ", format(Sys.time(), '%d/%m/%Y à %H:%M'), "
            </div>
            <p>Veuillez contacter l'administrateur du système.</p>
          </div>
        </body>
        </html>
      ")
      writeLines(error_html, file)
    })
  }
)

# Fonction pour récupérer les données de vote
get_votes_data <- function(selected_positions) {
  tryCatch({
    if(length(selected_positions) == 0) return(data.frame())
    
    position_placeholders <- paste(rep("?", length(selected_positions)), collapse = ",")
    
    dbGetQuery(values$con, sprintf("
      SELECT 
        c.name as candidate_name, 
        p.name as position_name,
        p.id as position_id,
        p.order_priority,
        p.category,
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
        c.id, c.name, p.name, p.id, p.order_priority, p.category
      ORDER BY 
        p.order_priority, vote_count DESC
      ", position_placeholders),
      params = as.list(selected_positions)
    )
  }, error = function(e) {
    cat("Erreur dans get_votes_data:", e$message, "\n")
    return(data.frame())
  })
}

# Fonction pour générer le HTML quand il n'y a pas de votes
generate_no_votes_html <- function() {
  paste0("
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='UTF-8'>
      <title>Procès-verbal d'élection</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 40px; background-color: #f8f9fa; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 25px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #3f51b5; padding-bottom: 20px; margin-bottom: 30px; }
        .title { color: #3f51b5; font-size: 28px; font-weight: bold; margin-bottom: 10px; }
        .date { color: #666; font-size: 16px; }
        .info-box { background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 20px; border-radius: 8px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class='container'>
        <div class='header'>
          <div class='title'>PROCÈS-VERBAL D'ÉLECTION</div>
          <div class='date'>", format(Sys.Date(), '%d/%m/%Y'), "</div>
        </div>
        <div class='info-box'>
          <h3>Aucun résultat disponible</h3>
          <p>Aucun vote n'a encore été enregistré dans le système. Le procès-verbal officiel sera disponible après la clôture des votes.</p>
        </div>
      </div>
    </body>
    </html>
  ")
}

# Fonction pour générer le HTML quand il n'y a pas de résultats
generate_no_results_html <- function() {
  paste0("
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='UTF-8'>
      <title>Procès-verbal d'élection</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 40px; background-color: #f8f9fa; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 25px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #3f51b5; padding-bottom: 20px; margin-bottom: 30px; }
        .title { color: #3f51b5; font-size: 28px; font-weight: bold; margin-bottom: 10px; }
        .date { color: #666; font-size: 16px; }
        .warning-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 8px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class='container'>
        <div class='header'>
          <div class='title'>PROCÈS-VERBAL D'ÉLECTION</div>
          <div class='date'>", format(Sys.Date(), '%d/%m/%Y'), "</div>
        </div>
        <div class='warning-box'>
          <h3>Aucun vote enregistré</h3>
          <p>Aucun vote n'a été enregistré pour les postes sélectionnés.</p>
        </div>
      </div>
    </body>
    </html>
  ")
}

# Fonction pour générer le HTML complet du procès-verbal
generate_pv_html <- function(votes_data) {
  # Obtenir la liste des postes uniques et les trier par ordre d'importance (order_priority)
  unique_positions <- unique(votes_data[, c("position_id", "position_name", "order_priority", "category")])
  unique_positions <- unique_positions[order(unique_positions$order_priority), ]
  
  # Commencer le HTML
  html <- paste0("
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='UTF-8'>
      <title>Procès-verbal d'élection</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 40px; background-color: #f8f9fa; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 25px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #3f51b5; padding-bottom: 20px; margin-bottom: 40px; }
        .title { color: #3f51b5; font-size: 32px; font-weight: bold; margin-bottom: 10px; }
        .date { color: #666; font-size: 18px; }
        .category-section { margin-bottom: 50px; }
        .category-title { color: #1976d2; font-size: 26px; font-weight: bold; margin-bottom: 30px; padding-bottom: 10px; border-bottom: 3px solid #1976d2; }
        .position-section { margin-bottom: 40px; border: 1px solid #ddd; border-radius: 10px; overflow: hidden; }
        .position-header { background: linear-gradient(135deg, #3f51b5, #303f9f); color: white; padding: 20px; font-size: 20px; font-weight: bold; }
        .position-content { padding: 25px; }
        .total-votes { background-color: #e8f5e8; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; color: #2e7d32; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; font-weight: bold; color: #3f51b5; }
        .winner-row { background-color: #e8f5e8; font-weight: bold; }
        .winner-box { background: linear-gradient(135deg, #4caf50, #45a049); color: white; padding: 20px; border-radius: 10px; margin-top: 20px; }
        .signatures { margin-top: 50px; padding-top: 30px; border-top: 2px solid #3f51b5; }
        .signature-line { margin: 30px 0; }
        .signature-label { font-weight: bold; margin-bottom: 10px; }
        .signature-underline { border-bottom: 1px solid #333; width: 300px; height: 20px; display: inline-block; }
        @media print { body { background: white; } .container { box-shadow: none; } }
      </style>
    </head>
    <body>
      <div class='container'>
        <div class='header'>
          <div class='title'>PROCÈS-VERBAL D'ÉLECTION</div>
          <div class='date'>Date du scrutin : ", format(Sys.Date(), '%d/%m/%Y'), "</div>
        </div>
  ")
  
  # Grouper les postes par catégorie
  categories <- unique(unique_positions$category)
  
  # Ajouter une section pour chaque catégorie
  for (category in categories) {
    category_positions <- unique_positions[unique_positions$category == category, ]
    
    html <- paste0(html, "
        <div class='category-section'>
          <h2 class='category-title'>", category, "</h2>
    ")
    
    # Ajouter une section pour chaque poste dans cette catégorie
    for (i in 1:nrow(category_positions)) {
      position_id <- category_positions$position_id[i]
      position_name <- category_positions$position_name[i]
    
    # Filtrer les données pour ce poste
    position_votes <- votes_data[votes_data$position_id == position_id, ]
    
    if(nrow(position_votes) == 0) next
    
    # Calculer le total des votes pour ce poste
    total_votes <- sum(position_votes$vote_count)
    
    # Calculer les pourcentages
    position_votes$percent <- round(position_votes$vote_count / total_votes * 100, 1)
    
    # Trouver le vainqueur
    winner <- position_votes[which.max(position_votes$vote_count), ]
    
      html <- paste0(html, "
          <div class='position-section'>
            <div class='position-header'>", position_name, "</div>
            <div class='position-content'>
              <div class='total-votes'>
                Total des votes exprimés : ", total_votes, " voix
              </div>
              <table>
                <thead>
                  <tr>
                    <th>Candidat</th>
                    <th>Nombre de voix</th>
                    <th>Pourcentage</th>
                  </tr>
                </thead>
                <tbody>
      ")
      
      # Ajouter les résultats de chaque candidat
      for (j in 1:nrow(position_votes)) {
        candidate <- position_votes[j, ]
        is_winner <- j == 1  # Le premier est le gagnant (trié par vote_count DESC)
        row_class <- if(is_winner) "winner-row" else ""
        
        html <- paste0(html, "
                  <tr class='", row_class, "'>
                    <td>", candidate$candidate_name, "</td>
                    <td>", candidate$vote_count, "</td>
                    <td>", candidate$percent, "%</td>
                  </tr>
        ")
      }
      
      html <- paste0(html, "
                </tbody>
              </table>
              <div class='winner-box'>
                <strong>CANDIDAT ÉLU :</strong><br>
                ", winner$candidate_name, " avec ", winner$vote_count, " voix (", winner$percent, "% des suffrages exprimés)
              </div>
            </div>
          </div>
      ")
    }
    
    # Fermer la section de catégorie
    html <- paste0(html, "
        </div>
    ")
  }
  
  # Ajouter la section signatures
  html <- paste0(html, "
        <div class='signatures'>
          <h3>Signatures</h3>
          <p><strong>Fait à _________________, le ", format(Sys.Date(), '%d/%m/%Y'), "</strong></p>
          
          <div class='signature-line'>
            <div class='signature-label'>Président du bureau de vote :</div>
            <div class='signature-underline'></div>
          </div>
          
          <div class='signature-line'>
            <div class='signature-label'>Assesseur 1 :</div>
            <div class='signature-underline'></div>
          </div>
          
          <div class='signature-line'>
            <div class='signature-label'>Assesseur 2 :</div>
            <div class='signature-underline'></div>
          </div>
        </div>
      </div>
    </body>
    </html>
  ")
  
  return(html)
}

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
        p.order_priority,
        p.category,
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
        c.id, p.order_priority, p.category
      ORDER BY 
        p.order_priority, vote_count DESC
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
  
  # Obtenir la liste des postes sélectionnés qui ont des votes et les trier par ordre d'importance
  unique_positions <- unique(votes_data[, c("position_id", "position_name", "order_priority", "category")])
  unique_positions <- unique_positions[order(unique_positions$order_priority), ]
  
  # Grouper les postes par catégorie et créer des sections
  categories <- unique(unique_positions$category)
  category_sections <- lapply(categories, function(category) {
    category_positions <- unique_positions[unique_positions$category == category, ]
    
    # Créer des tableaux pour chaque poste de cette catégorie
    position_tables <- lapply(1:nrow(category_positions), function(i) {
      position_id <- category_positions$position_id[i]
      position_name <- category_positions$position_name[i]
    
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
  
    # Retourner la section de catégorie avec son titre
    div(class = "category-section mb-5",
        h3(class = "category-title mb-4", 
           style = "color: #1976d2; font-size: 24px; font-weight: bold; border-bottom: 3px solid #1976d2; padding-bottom: 10px;",
           icon(if(category == "Bureau exécutif") "users-cog" else "building", class = "me-2"),
           category
        ),
        position_tables
    )
  })
  
  # Combiner toutes les sections de catégorie
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
    category_sections,
    div(class = "text-end text-muted small mt-4",
        icon("clock", class = "me-1"),
        "Résultats générés le ", format(Sys.time(), "%d/%m/%Y à %H:%M")
    )
  )
})

# Fonction pour générer le HTML quand il n'y a pas de résultats
generate_no_results_html <- function() {
  paste0("
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='UTF-8'>
      <title>Procès-verbal d'élection</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 40px; background-color: #f8f9fa; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 25px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #3f51b5; padding-bottom: 20px; margin-bottom: 30px; }
        .title { color: #3f51b5; font-size: 28px; font-weight: bold; margin-bottom: 10px; }
        .date { color: #666; font-size: 16px; }
        .warning-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 8px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class='container'>
        <div class='header'>
          <div class='title'>PROCÈS-VERBAL D'ÉLECTION</div>
          <div class='date'>", format(Sys.Date(), '%d/%m/%Y'), "</div>
        </div>
        <div class='warning-box'>
          <h3>Aucun vote enregistré</h3>
          <p>Aucun vote n'a été enregistré pour les postes sélectionnés.</p>
        </div>
      </div>
    </body>
    </html>
  ")
}
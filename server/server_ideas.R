# server/server_ideas.R - Gestion des suggestions d'amélioration

# Créer la table pour stocker les idées à l'intérieur d'un contexte réactif
observe({
  # S'assurer que la connexion est disponible
  req(values$con)
  
  # Créer la table si elle n'existe pas
  dbExecute(values$con, "
    CREATE TABLE IF NOT EXISTS ideas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT DEFAULT 'Anonyme',
      category TEXT NOT NULL,
      text TEXT NOT NULL,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )")
})

# Traitement du formulaire de soumission d'idée
observeEvent(input$submit_idea, {
  # Permettre la soumission même avec un texte court, mais pas vide
  req(input$idea_text)
  
  # Vérifier si l'option anonyme est cochée
  name <- if(!is.null(input$anonymous_idea) && input$anonymous_idea) {
    "Anonyme"
  } else if (user$authenticated) {
    user$name
  } else {
    "Utilisateur"
  }
  
  # Insertion dans la base de données
  tryCatch({
    dbExecute(values$con, 
      "INSERT INTO ideas (name, category, text) VALUES (?, ?, ?)",
      params = list(name, input$idea_category, input$idea_text)
    )
    
    # Reset du formulaire
    updateTextAreaInput(session, "idea_text", value = "")
    
    # Notification de confirmation
    showNotification("Votre suggestion a été enregistrée. Merci pour votre contribution!", 
                     type = "message", duration = 5)
  }, error = function(e) {
    # En cas d'erreur, afficher une notification
    showNotification(paste("Erreur lors de l'enregistrement:", e$message), 
                     type = "error", duration = 5)
  })
}, ignoreNULL = FALSE, ignoreInit = TRUE)

# Bouton de rafraîchissement
observeEvent(input$refresh_ideas, {
  # Forcer l'actualisation en déclenchant une réactivité
  session$sendCustomMessage(type = "trigger-ideas-refresh", message = list(time = as.numeric(Sys.time())))
  
  # Notification
  showNotification("Liste des suggestions actualisée", type = "message", duration = 2)
})

# Affichage des idées déjà soumises
output$ideas_list <- renderUI({
  # Observer input$refresh_ideas pour forcer l'actualisation
  input$refresh_ideas
  
  # Récupérer les suggestions selon le filtre
  query <- if (input$filter_ideas == "all") {
    "SELECT * FROM ideas ORDER BY timestamp DESC"
  } else {
    "SELECT * FROM ideas WHERE category = ? ORDER BY timestamp DESC"
  }
  
  params <- if (input$filter_ideas == "all") list() else list(input$filter_ideas)
  
  ideas <- tryCatch({
    dbGetQuery(values$con, query, params = params)
  }, error = function(e) {
    # En cas d'erreur, retourner un tableau vide
    data.frame(id = integer(), name = character(), category = character(), 
               text = character(), timestamp = character())
  })
  
  if (nrow(ideas) == 0) {
    return(div(class = "alert alert-info", 
               "Aucune suggestion n'a encore été soumise dans cette catégorie."))
  }
  
  # Mapper les catégories à des étiquettes plus lisibles
  category_labels <- c(
    "interface" = "Interface de vote",
    "organisation" = "Organisation des élections",
    "candidats" = "Présentation des candidats",
    "processus" = "Processus électoral",
    "autre" = "Autre suggestion"
  )
  
  # Couleurs associées aux catégories
  category_colors <- c(
    "interface" = "#17a2b8",
    "organisation" = "#fd7e14",
    "candidats" = "#6f42c1",
    "processus" = "#20c997",
    "autre" = "#6c757d"
  )
  
  # Créer une carte pour chaque idée avec le nouveau style
  cards <- lapply(1:nrow(ideas), function(i) {
    idea <- ideas[i, ]
    category_label <- category_labels[idea$category]
    category_color <- category_colors[idea$category]
    
    if (is.na(category_label)) category_label <- idea$category
    if (is.na(category_color)) category_color <- "#6c757d"
    
    # Formatage de la date pour affichage
    date_formatted <- format(as.POSIXct(idea$timestamp), "%d/%m/%Y")
    time_formatted <- format(as.POSIXct(idea$timestamp), "%H:%M")
    
    div(class = paste("idea-card p-3 rounded shadow-sm", idea$category),
      div(class = "d-flex justify-content-between align-items-start mb-2",
        div(class = "d-flex align-items-center",
          div(class = "me-2", style = paste0("width: 5px; height: 40px; background-color: ", category_color, "; border-radius: 2px;")),
          div(
            h5(class = "mb-1", idea$text),
            div(class = "idea-meta", 
              span(class = "me-2", icon("user", class = "me-1"), idea$name),
              span(icon("calendar", class = "me-1"), date_formatted),
              span(class = "ms-2", icon("clock", class = "me-1"), time_formatted)
            )
          )
        ),
        span(class = paste0("idea-category badge bg-", switch(idea$category,
          "interface" = "primary",
          "organisation" = "success",
          "candidats" = "purple",
          "processus" = "warning",
          "autre" = "secondary"
        )), category_label)
      )
    )
  })
  
  # Retourner tous les cards avec script d'initialisation
  tagList(
    div(class = "ideas-list", cards),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('trigger-ideas-refresh', function(message) {
        // Juste pour forcer une réactivité
        console.log('Refresh ideas list: ' + message.time);
      });
    "))
  )
})

# Graphique de répartition des suggestions par catégorie
output$ideas_chart <- renderPlot({
  # Récupérer les données
  ideas_count <- dbGetQuery(values$con, 
                          "SELECT category, COUNT(*) as count FROM ideas GROUP BY category")
  
  if (nrow(ideas_count) == 0) {
    return(NULL)
  }
  
  # Ajouter les étiquettes des catégories
  category_labels <- c(
    "interface" = "Interface de vote",
    "organisation" = "Organisation des élections",
    "candidats" = "Présentation des candidats",
    "processus" = "Processus électoral",
    "autre" = "Autre suggestion"
  )
  
  ideas_count$category_label <- sapply(ideas_count$category, function(cat) {
    label <- category_labels[cat]
    if (is.na(label)) cat else label
  })
  
  # Créer le graphique
  ggplot(ideas_count, aes(x = reorder(category_label, -count), y = count, fill = category_label)) +
    geom_col() +
    geom_text(aes(label = count), vjust = -0.5) +
    scale_fill_brewer(palette = "Set3") +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(x = "Catégories", y = "Nombre de suggestions",
         title = "Répartition des suggestions par catégorie")
})

# Récupérer les idées populaires
output$popular_ideas <- renderUI({
  # Récupérer les 3 idées les plus récentes
  popular_ideas <- tryCatch({
    dbGetQuery(values$con, "
      SELECT * FROM ideas 
      ORDER BY timestamp DESC 
      LIMIT 3
    ")
  }, error = function(e) {
    return(data.frame())
  })
  
  if(nrow(popular_ideas) == 0) {
    return(div(class = "alert alert-info", 
               "Aucune suggestion n'a encore été soumise."))
  }
  
  # Mapper les catégories à des étiquettes et couleurs
  category_info <- list(
    "interface" = list(label = "Interface de vote", color = "primary", icon = "laptop"),
    "organisation" = list(label = "Organisation des élections", color = "success", icon = "calendar"),
    "candidats" = list(label = "Présentation des candidats", color = "info", icon = "video"),
    "processus" = list(label = "Processus électoral", color = "warning", icon = "chart-pie"),
    "autre" = list(label = "Autre suggestion", color = "secondary", icon = "lightbulb")
  )
  
  # Créer les cartes pour chaque idée populaire
  div(class = "row",
    lapply(1:nrow(popular_ideas), function(i) {
      idea <- popular_ideas[i,]
      category <- category_info[[idea$category]]
      
      div(class = "col-md-4 mb-3",
        div(class = "popular-idea p-3 h-100 border rounded",
          div(class = "d-flex align-items-center mb-2",
            icon(category$icon, class = sprintf("text-%s me-2", category$color)),
            h5(class = "mb-0", idea$name)
          ),
          p(class = "text-muted small", idea$text),
          div(class = "text-end",
            span(class = sprintf("badge bg-%s", category$color), category$label)
          )
        )
      )
    })
  )
}) 
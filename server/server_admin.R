admin_server <- function(id, connection, positions) {
  moduleServer(id, function(input, output, session) {
    # Ajouter des messages de débogage pour tracer l'initialisation du module
    cat("Module admin initialisé avec ID:", id, "\n")
    
    # Tracer les entrées réactives pour le débogage
    observe({
      cat("Entrées réactives admin:", names(input), "\n")
      if ("reset_system" %in% names(input)) {
        cat("Reset button value:", input$reset_system, "\n")
      }
      if ("export_votes" %in% names(input)) {
        cat("Export button value:", input$export_votes, "\n")
      }
    })
    
    # Réactives pour stocker les données
    votes_data <- reactive({
      # Récupérer les votes avec jointure pour obtenir les noms des candidats et des postes
      query <- "
        SELECT v.id, v.voter_id, c.name as candidate_name, p.name as position_name, 
               v.timestamp, v.hash
        FROM votes v
        LEFT JOIN candidates c ON v.candidate_id = c.id
        LEFT JOIN positions p ON v.position_id = p.id
        ORDER BY v.timestamp DESC
      "
      dbGetQuery(connection, query)
    })
    
    # Calculer les statistiques générales
    output$total_votes <- renderText({
      nrow(votes_data())
    })
    
    output$total_voters <- renderText({
      query <- "SELECT COUNT(DISTINCT voter_id) as count FROM votes"
      dbGetQuery(connection, query)$count
    })
    
    output$participation_rate <- renderText({
      total_voters <- dbGetQuery(connection, "SELECT COUNT(DISTINCT voter_id) as count FROM votes")$count
      total_students <- dbGetQuery(connection, "SELECT COUNT(*) as count FROM voters")$count
      
      if (total_students > 0) {
        rate <- total_voters / total_students * 100
        return(paste0(round(rate, 1), "%"))
      } else {
        return("0%")
      }
    })
    
    # Remplir le sélecteur de position avec les postes existants
    observe({
      position_choices <- c("Tous les postes" = "")
      if (!is.null(positions) && nrow(positions) > 0) {
        position_names <- positions$name
        named_list <- setNames(positions$id, position_names)
        position_choices <- c(position_choices, named_list)
      }
      updateSelectInput(session, "vote_filter_position", choices = position_choices)
    })
    
    # Filtrer les votes en fonction des critères
    filtered_votes <- reactive({
      # Commencer avec tous les votes
      votes <- votes_data()
      if (nrow(votes) == 0) return(votes)
      
      # Filtrer par position si sélectionné
      if (!is.null(input$vote_filter_position) && input$vote_filter_position != "") {
        position_id <- as.numeric(input$vote_filter_position)
        votes <- votes[votes$position_id == position_id, ]
      }
      
      # Filtrer par date
      if (!is.null(input$vote_filter_date)) {
        start_date <- as.Date(input$vote_filter_date[1])
        end_date <- as.Date(input$vote_filter_date[2]) + 1 # Ajouter un jour pour inclure la fin
        
        # Convertir les timestamps en dates pour comparer
        votes$date <- as.Date(votes$timestamp)
        votes <- votes[votes$date >= start_date & votes$date <= end_date, ]
      }
      
      # Filtrer par recherche textuelle
      if (!is.null(input$vote_filter_search) && input$vote_filter_search != "") {
        search_term <- tolower(input$vote_filter_search)
        votes <- votes[
          grepl(search_term, tolower(votes$voter_id)) | 
          grepl(search_term, tolower(votes$candidate_name)) |
          grepl(search_term, tolower(votes$position_name)),
        ]
      }
      
      return(votes)
    })
    
    # Table des votes
    output$votes_table <- DT::renderDataTable({
      req(filtered_votes())
      votes <- filtered_votes()
      
      if (nrow(votes) == 0) {
        return(data.frame(Message = "Aucun vote trouvé avec ces critères."))
      }
      
      # Formater la table pour l'affichage
      display_data <- votes[, c("id", "voter_id", "candidate_name", "position_name", "timestamp")]
      colnames(display_data) <- c("ID", "Électeur", "Candidat", "Poste", "Date du vote")
      
      DT::datatable(
        display_data,
        selection = "multiple",
        options = list(
          pageLength = 10,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel', 'pdf'),
          language = list(
            search = "Rechercher:",
            lengthMenu = "Afficher _MENU_ entrées",
            info = "Affichage de _START_ à _END_ sur _TOTAL_ entrées",
            paginate = list(
              previous = "Précédent",
              `next` = "Suivant"
            )
          )
        )
      )
    })
    
    # Téléchargement des votes en CSV
    output$download_votes_csv <- downloadHandler(
      filename = function() {
        paste("votes-export-", format(Sys.Date(), "%Y-%m-%d"), ".csv", sep = "")
      },
      content = function(file) {
        votes <- filtered_votes()
        write.csv(votes, file, row.names = FALSE)
      }
    )
    
    # Exportation de tous les votes
    output$export_votes <- downloadHandler(
      filename = function() {
        paste("votes-complets-", format(Sys.Date(), "%Y-%m-%d"), ".csv", sep = "")
      },
      content = function(file) {
        # Message de débogage
        cat("Fonction d'exportation appelée\n")
        
        # Récupérer tous les votes avec les informations détaillées
        query <- "
          SELECT v.id, v.voter_id, c.name as candidat, p.name as poste, 
                 v.timestamp as date_vote, v.hash
          FROM votes v
          LEFT JOIN candidates c ON v.candidate_id = c.id
          LEFT JOIN positions p ON v.position_id = p.id
          ORDER BY v.timestamp DESC
        "
        all_votes <- dbGetQuery(connection, query)
        
        # Message de débogage
        cat("Données récupérées:", nrow(all_votes), "votes\n")
        
        # Écrire dans le fichier CSV
        write.csv(all_votes, file, row.names = FALSE)
        
        # Notification d'exportation réussie
        showNotification("Exportation des votes réussie!", type = "message", duration = 5)
      }
    )
    
    # Action pour supprimer les votes sélectionnés
    observeEvent(input$delete_selected_votes, {
      # Obtenir les lignes sélectionnées
      selected_rows <- input$votes_table_rows_selected
      
      if (length(selected_rows) == 0) {
        showNotification("Aucun vote sélectionné.", type = "warning")
        return()
      }
      
      # Obtenir les IDs des votes à supprimer
      votes_to_delete <- filtered_votes()[selected_rows, "id"]
      
      # Construire la requête SQL
      if (length(votes_to_delete) == 1) {
        query <- paste0("DELETE FROM votes WHERE id = ", votes_to_delete)
      } else {
        ids_string <- paste(votes_to_delete, collapse = ",")
        query <- paste0("DELETE FROM votes WHERE id IN (", ids_string, ")")
      }
      
      # Confirmation avant suppression
      showModal(modalDialog(
        title = "Confirmation de suppression",
        HTML(paste0("Êtes-vous sûr de vouloir supprimer <strong>", length(votes_to_delete), 
                  "</strong> vote(s) ? Cette action est irréversible.")),
        footer = tagList(
          actionButton("confirm_delete", "Supprimer", class = "btn btn-danger"),
          modalButton("Annuler")
        ),
        easyClose = TRUE
      ))
      
      # Stocker la requête pour utilisation ultérieure
      session$userData$delete_query <- query
    })
    
    # Confirmer la suppression des votes
    observeEvent(input$confirm_delete, {
      query <- session$userData$delete_query
      
      if (!is.null(query)) {
        # Exécuter la requête de suppression
        result <- dbExecute(connection, query)
        
        if (result > 0) {
          showNotification(paste(result, "vote(s) supprimé(s) avec succès."), type = "message")
        } else {
          showNotification("Erreur lors de la suppression des votes.", type = "error")
        }
        
        # Effacer la requête stockée
        session$userData$delete_query <- NULL
      }
      
      # Fermer la boîte de dialogue
      removeModal()
    })
    
    # Réinitialisation du système
    observeEvent(input$reset_system, {
      # Message de débogage
      cat("Bouton de réinitialisation cliqué\n")
      
      # Notification immédiate que le processus est en cours
      showNotification("Traitement de la demande de réinitialisation en cours...", type = "message", duration = NULL, id = "reset_process")
      
      # Vérifier la confirmation avec l'identifiant administrateur
      admin_ids <- c("admin1", "admin2", "admin3")
      if (is.null(input$reset_confirmation) || !(input$reset_confirmation %in% admin_ids)) {
        showNotification("Veuillez saisir votre identifiant administrateur valide pour confirmer l'opération.", 
                         type = "warning", duration = 5)
        removeNotification(id = "reset_process")
        return()
      }
      
      # Préparer la requête SQL pour supprimer les votes
      query <- "DELETE FROM votes"
      
      # Exécuter la requête
      tryCatch({
        # Récupérer le nombre de votes avant suppression
        vote_count <- dbGetQuery(connection, "SELECT COUNT(*) as count FROM votes")$count
        
        # Exécuter la suppression
        dbExecute(connection, query)
        
        # Effacer la notification de traitement
        removeNotification(id = "reset_process")
        
        # Afficher un message de succès
        showNotification(
          HTML(paste0("<strong>Réinitialisation réussie</strong><br>", 
                     vote_count, " votes ont été supprimés.")),
          type = "message",
          duration = 5
        )
        
        # Effacer la confirmation
        updateTextInput(session, "reset_confirmation", value = "")
        
      }, error = function(e) {
        # Effacer la notification de traitement
        removeNotification(id = "reset_process")
        
        # Afficher l'erreur
        showNotification(paste("Erreur lors de la réinitialisation:", e$message), type = "error")
      })
    })
    
    # Statistiques de la base de données
    output$db_tables_count <- renderText({
      # Obtenir la liste des tables
      tables <- dbListTables(connection)
      length(tables)
    })
    
    output$db_size <- renderText({
      # Obtenir la taille du fichier de base de données
      db_file <- "data/elections.db"
      if (file.exists(db_file)) {
        size_bytes <- file.info(db_file)$size
        if (size_bytes < 1024) {
          return(paste(size_bytes, "octets"))
        } else if (size_bytes < 1024^2) {
          return(paste(round(size_bytes / 1024, 2), "Ko"))
        } else {
          return(paste(round(size_bytes / 1024^2, 2), "Mo"))
        }
      } else {
        return("Fichier non trouvé")
      }
    })
    
    output$db_last_modified <- renderText({
      # Obtenir la date de dernière modification
      db_file <- "data/elections.db"
      if (file.exists(db_file)) {
        mtime <- file.info(db_file)$mtime
        format(mtime, "%d/%m/%Y %H:%M:%S")
      } else {
        return("Fichier non trouvé")
      }
    })
    
    # Aperçu de la table sélectionnée
    output$db_table_preview <- DT::renderDataTable({
      req(input$db_table_view)
      
      table_name <- input$db_table_view
      
      if (dbExistsTable(connection, table_name)) {
        # Limiter à 100 lignes pour éviter de surcharger l'interface
        query <- paste0("SELECT * FROM ", table_name, " LIMIT 100")
        data <- dbGetQuery(connection, query)
        
        DT::datatable(
          data,
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            language = list(
              search = "Rechercher:",
              lengthMenu = "Afficher _MENU_ entrées",
              info = "Affichage de _START_ à _END_ sur _TOTAL_ entrées",
              paginate = list(
                previous = "Précédent",
                `next` = "Suivant"
              )
            )
          )
        )
      } else {
        return(data.frame(Message = "Table non trouvée."))
      }
    })
    
  })
} 
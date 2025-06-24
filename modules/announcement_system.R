# Module pour le système d'annonces administratives
# Gestion des annonces pour les électeurs avec persistance en base de données

# UI du module d'annonces
announcementSystemUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Interface d'administration des annonces (visible uniquement pour les admins)
    conditionalPanel(
      condition = "input.user_is_admin == true",
      div(class = "announcement-admin-panel",
          card(
            card_header(
              h4("📢 Système d'Annonces", class = "mb-0")
            ),
            card_body(
              wellPanel(
                h5("Envoyer une annonce aux électeurs"),
                fluidRow(
                  column(8,
                         textInput(ns("ann_title"), "Titre de l'annonce",
                                  placeholder = "Ex: Prolongation du vote jusqu'à 18h")),
                  column(4,
                         selectInput(ns("ann_priority"), "Priorité",
                                    choices = list(
                                      "🔵 Normale" = "normal",
                                      "🟡 Importante" = "important", 
                                      "🔴 Urgente" = "urgent"
                                    ), selected = "normal"))
                ),
                textAreaInput(ns("ann_message"), "Message",
                             placeholder = "Votre message aux électeurs...",
                             rows = 3),
                fluidRow(
                  column(6,
                         selectInput(ns("ann_type"), "Type d'affichage",
                                    choices = list(
                                      "Notification popup" = "notification",
                                      "Bannière en haut" = "banner",
                                      "Les deux" = "both"
                                    ), selected = "notification")),
                  column(6,
                         selectInput(ns("ann_target"), "Public cible",
                                    choices = list(
                                      "Tous les utilisateurs" = "all",
                                      "Étudiants uniquement" = "students",
                                      "Délégués uniquement" = "delegates"
                                    ), selected = "all"))
                ),
                div(class = "d-flex justify-content-between align-items-center mt-3",
                    div(class = "text-muted",
                        icon("info-circle"), " L'annonce sera envoyée immédiatement à tous les utilisateurs connectés"
                    ),
                    actionButton(ns("send_announcement"), "📢 Envoyer l'annonce", 
                               class = "btn-primary btn-lg")
                )
              ),
              
              # Historique des annonces récentes
              hr(),
              h5("Annonces récentes"),
              div(id = ns("recent_announcements"),
                  em("Aucune annonce récente", class = "text-muted")
              )
            )
          )
      )
    ),
    
    # CSS pour le système d'annonces
    tags$style(HTML("
      .announcement-admin-panel .card {
        border: 2px solid #e3f2fd;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
      }
      
      .announcement-admin-panel .card-header {
        background: linear-gradient(135deg, #2196F3, #1976D2);
        color: white;
      }
      
      .recent-announcement-item {
        background: #f8f9fa;
        border-left: 4px solid #2196F3;
        padding: 10px 15px;
        margin-bottom: 10px;
        border-radius: 0 8px 8px 0;
        position: relative;
      }
      
      .recent-announcement-item.priority-important {
        border-left-color: #ff9800;
        background: #fff8e1;
      }
      
      .recent-announcement-item.priority-urgent {
        border-left-color: #f44336;
        background: #ffebee;
        animation: pulse-urgent 2s infinite;
      }
      
      .announcement-time {
        position: absolute;
        top: 5px;
        right: 10px;
        font-size: 0.8rem;
        color: #666;
      }
      
      .announcement-title {
        font-weight: 600;
        color: #2c3e50;
        margin-bottom: 5px;
      }
      
      .announcement-message {
        color: #555;
        font-size: 0.9rem;
      }
      
      .announcement-stats {
        margin-top: 8px;
        font-size: 0.8rem;
        color: #666;
      }
      
      @keyframes pulse-urgent {
        0% { background: #ffebee; }
        50% { background: #ffcdd2; }
        100% { background: #ffebee; }
      }
    "))
  )
}

# Server du module d'annonces
announcementSystemServer <- function(id, con, notification_handlers) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Créer la table des annonces si elle n'existe pas
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        priority TEXT DEFAULT 'normal',
        type TEXT DEFAULT 'notification',
        target_audience TEXT DEFAULT 'all',
        created_by TEXT DEFAULT 'admin',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        sent_count INTEGER DEFAULT 0
      )")
    
    # Reactive pour les annonces récentes
    recent_announcements <- reactive({
      invalidateLater(5000) # Actualiser toutes les 5 secondes
      tryCatch({
        dbGetQuery(con, "
          SELECT * FROM announcements 
          ORDER BY created_at DESC 
          LIMIT 5
        ")
      }, error = function(e) {
        data.frame() # Retourner un data.frame vide en cas d'erreur
      })
    })
    
    # Envoyer une annonce
    observeEvent(input$send_announcement, {
      req(input$ann_title, input$ann_message)
      
      # Validation
      if (nchar(trimws(input$ann_title)) == 0 || nchar(trimws(input$ann_message)) == 0) {
        showNotification("Le titre et le message sont obligatoires", type = "error")
        return()
      }
      
      tryCatch({
        # Sauvegarder l'annonce en base de données
        dbExecute(con, "
          INSERT INTO announcements 
          (title, message, priority, type, target_audience, created_by, sent_count)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ", list(
          input$ann_title,
          input$ann_message,
          input$ann_priority,
          input$ann_type,
          input$ann_target,
          "admin",
          1
        ))
        
        # Déterminer le type de notification selon la priorité
        urgent <- input$ann_priority == "urgent"
        
        # Envoyer selon le type choisi
        if (input$ann_type %in% c("notification", "both")) {
          # Envoyer une notification push
          notification_handlers$sendPushNotification(
            input$ann_title,
            input$ann_message,
            type = input$ann_priority,
            urgent = urgent
          )
        }
        
        if (input$ann_type %in% c("banner", "both")) {
          # Afficher une bannière en haut de page
          notification_handlers$showGlobalAnnouncement(
            input$ann_title,
            input$ann_message,
            priority = input$ann_priority
          )
        }
        
        # Notification de succès
        success_emoji <- switch(input$ann_priority,
                               "urgent" = "🚨",
                               "important" = "⚠️",
                               "✅")
        
        showNotification(
          paste0(success_emoji, " Annonce envoyée avec succès !"),
          type = "success",
          duration = 3
        )
        
        # Réinitialiser le formulaire
        updateTextInput(session, "ann_title", value = "")
        updateTextAreaInput(session, "ann_message", value = "")
        updateSelectInput(session, "ann_priority", selected = "normal")
        updateSelectInput(session, "ann_type", selected = "notification")
        updateSelectInput(session, "ann_target", selected = "all")
        
      }, error = function(e) {
        showNotification(
          paste("❌ Erreur lors de l'envoi:", e$message), 
          type = "error",
          duration = 5
        )
      })
    })
    
    # Fonction pour obtenir les statistiques des annonces
    get_announcement_stats <- function() {
      tryCatch({
        stats <- dbGetQuery(con, "
          SELECT 
            COUNT(*) as total_announcements,
            SUM(sent_count) as total_sends,
            COUNT(CASE WHEN priority = 'urgent' THEN 1 END) as urgent_count,
            COUNT(CASE WHEN created_at >= date('now', '-1 day') THEN 1 END) as recent_count
          FROM announcements
        ")
        return(stats)
      }, error = function(e) {
        return(data.frame(
          total_announcements = 0,
          total_sends = 0,
          urgent_count = 0,
          recent_count = 0
        ))
      })
    }
    
    # Retourner les fonctions utiles
    list(
      get_announcement_stats = get_announcement_stats
    )
  })
} 
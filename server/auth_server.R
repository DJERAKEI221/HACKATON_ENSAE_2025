auth_server <- function(id, students_df, rv_user) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Function to render the authentication UI
    output$auth_screen_ui <- renderUI({
      # Cacher complètement l'interface d'authentification si déjà authentifié
      if (rv_user$authenticated) {
        return(NULL)
      }

      # Charger et utiliser l'interface d'authentification existante
      source("ui/ui_auth.R", local = TRUE)
      auth_ui_content(ns)
    })

    # Observer pour détecter quand l'utilisateur tape son identifiant
    observeEvent(input$accessCode, {
      req(input$accessCode)
      
      # Si l'identifiant a au moins 3 caractères, chercher dans la base
      if (nchar(input$accessCode) >= 3) {
        # Chercher l'étudiant dans les données CSV
        student_info <- students_df[students_df$Identifiant == input$accessCode, ]
        
        if (nrow(student_info) > 0) {
          # Étudiant trouvé - afficher et remplir les autres champs
          shinyjs::show("user_info_fields")
          
          # Remplir automatiquement les champs
          updateTextInput(session, "lastName", value = student_info$Nom[1])
          updateTextInput(session, "firstName", value = student_info$Prenom[1])
          updateSelectInput(session, "studentYear", selected = student_info$Classe[1])
          
          # Montrer une notification de confirmation
          showNotification(paste0("Informations trouvées pour: ", student_info$Prenom[1], " ", student_info$Nom[1]), 
                          type = "message", duration = 3)
        } else {
          # Masquer les champs si l'identifiant n'est pas trouvé
          shinyjs::hide("user_info_fields")
        }
      } else {
        # Masquer les champs si l'identifiant est trop court
        shinyjs::hide("user_info_fields")
      }
    })

    # Observe login button click
    observeEvent(input$login, {
      req(input$accessCode) # Only need the identifier for initial lookup

      # Get the student ID from the input field
      student_id_input <- input$accessCode

      # Look up the student in the loaded CSV data
      student_info <- students_df[students_df$Identifiant == student_id_input, ]

      if (nrow(student_info) > 0) {
        # Student found - update reactive values and UI

        # Store user info in reactive values (now passed as argument)
        rv_user$authenticated <- TRUE
        rv_user$id <- student_info$Identifiant[1] # Use the identifier from CSV as user ID
        rv_user$year <- student_info$Classe[1] # Store class from CSV
        rv_user$name <- student_info$Nom[1] # Store last name from CSV
        rv_user$firstName <- student_info$Prenom[1] # Store first name from CSV

        # Show success message and potentially hide the login form elements
        shinyjs::show("auth_success")
        shinyjs::show("auth_nav_buttons")
         # Hide the login form elements but keep the "Authentification réussie" message visible for a moment
        shinyjs::hide(selector = paste0("#", ns("auth_screen_ui"), " .auth-card-body .form-group")) # Hide form groups
        shinyjs::hide(selector = paste0("#", ns("login"))) # Hide login button

        # Montrer une notification de succès
        showNotification(paste0("Authentification réussie! Bienvenue, ", student_info$Prenom[1], " ", student_info$Nom[1]),
                         type = "message", duration = 5)

        # After a short delay, navigate
        shinyjs::delay(2000, {
           # Masquer l'écran d'authentification en masquant le div principal du module UI
          shinyjs::hide(selector = paste0("#", ns("auth_screen_ui")))
          # Naviguer vers la page d'accueil
          updateNavbarPage(session, "main_navbar", selected = "Accueil")
        })

      } else {
        # Student not found - show error message
        showNotification("Identifiant invalide. Veuillez réessayer.", type = "error", duration = 5)
        # Optionally clear the input field
        updateTextInput(session, "accessCode", value = "")
      }
    })

    # Navigation après authentification
    observeEvent(input$goto_home, {
      updateNavbarPage(session, "main_navbar", selected = "Accueil")
    })

    observeEvent(input$goto_candidates, {
      updateNavbarPage(session, "main_navbar", selected = "Candidats")
    })

    observeEvent(input$goto_vote, {
      updateNavbarPage(session, "main_navbar", selected = "Vote")
    })

    observeEvent(input$goto_results, {
      updateNavbarPage(session, "main_navbar", selected = "Résultats")
    })

    # Return the reactive values containing user info
    return(rv_user)
  })
} 
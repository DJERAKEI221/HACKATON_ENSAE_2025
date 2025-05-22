div(class = "container vote-container",
  div(class = "spacer", style = "height: 10px;"),
  
  # Message d'avertissement de connexion
  uiOutput("login_warning"),
  
  # Interface de vote avec un design amélioré
  hidden(
    div(id = "vote_interface", class = "vote-interface-container",
      # Banner de vote
      div(class = "vote-banner mb-4 text-center bg-primary text-white p-4 rounded shadow-sm",
        div(class = "row align-items-center",
          div(class = "col-md-2 text-center d-none d-md-block", 
            icon("vote-yea", class = "fa-3x mb-2")
          ),
          div(class = "col-md-8",
            h2("Exprimez votre choix", class = "mb-2"),
            p(class = "lead mb-0", "Votre vote est anonyme et sécurisé")
          ),
          div(class = "col-md-2 text-center d-none d-md-block", 
            icon("lock", class = "fa-3x mb-2")
          )
        )
      ),
      
      # Section principale de vote
      div(class = "row",
        # Carte de sélection des postes
        div(class = "col-lg-4 mb-4",
          bslib::card(class = "shadow-sm h-100 border-left-primary", style = "border-left: 4px solid #dee2e6;",
            bslib::card_header(class = "bg-light",
              div(class = "d-flex align-items-center", 
                icon("briefcase", class = "me-2 text-primary"),
                h3("Postes à pourvoir", class = "mb-0 fs-4")
              )
            ),
            bslib::card_body(
              p(class = "text-muted mb-3", "Sélectionnez un poste pour afficher les candidats"),
              # Conteneur des boutons de position - sans aucune restriction
              uiOutput("vote_position_buttons")
            )
          )
        ),
        
        # Carte des candidats
        div(class = "col-lg-8",
          bslib::card(class = "shadow-sm border-left-success", style = "border-left: 4px solid #dee2e6;",
            bslib::card_header(class = "bg-light",
              div(class = "d-flex align-items-center justify-content-between", 
                icon("users", class = "me-2 text-success"),
                h3("Candidats", class = "mb-0 fs-4"),
                # Indicateur de progression déplacé ici
                div(class = "d-flex align-items-center",
                  div(class = "progress mx-2", style = "width: 100px; height: 5px;",
                    div(id = "vote_progress", class = "progress-bar bg-success", 
                        role = "progressbar", style = "width: 0%;", 
                        "aria-valuenow" = "0", "aria-valuemin" = "0", "aria-valuemax" = "100")
                  ),
                  div(class = "text-muted small", id = "vote_progress_text", style = "font-size: 0.75rem; white-space: nowrap;")
                )
              )
            ),
            bslib::card_body(
              div(id = "candidates_container", class = "p-2",
                uiOutput("candidates_panel")
              )
            ),
            bslib::card_footer(class = "bg-light",
              div(class = "d-flex justify-content-between align-items-center",
                div(class = "text-muted small fst-italic",
                  icon("info-circle", class = "me-1"),
                  "Votre vote restera confidentiel"
                ),
                div(id = "vote_confirmation_status")
              )
            )
          )
        )
      ),
      
      # Informations sur le processus de vote
      div(class = "row mt-4",
        div(class = "col-12",
          bslib::card(class = "shadow-sm border-info", style = "border-left: 4px solid #dee2e6;",
            bslib::card_header(class = "bg-light",
              div(class = "d-flex align-items-center", 
                icon("question-circle", class = "me-2 text-info"),
                h4("Comment voter ?", class = "mb-0")
              )
            ),
            bslib::card_body(
              div(class = "row",
                div(class = "col-md-4 mb-3",
                  div(class = "d-flex align-items-center",
                    div(class = "me-3 text-center", style = "width: 40px; height: 40px; background-color: #e9ecef; border-radius: 50%; line-height: 40px;",
                      span("1", class = "fw-bold")
                    ),
                    div(
                      h5("Sélectionnez un poste", class = "mb-1"),
                      p(class = "text-muted small mb-0", "Choisissez parmi les postes disponibles")
                    )
                  )
                ),
                div(class = "col-md-4 mb-3",
                  div(class = "d-flex align-items-center",
                    div(class = "me-3 text-center", style = "width: 40px; height: 40px; background-color: #e9ecef; border-radius: 50%; line-height: 40px;",
                      span("2", class = "fw-bold")
                    ),
                    div(
                      h5("Examinez les candidats", class = "mb-1"),
                      p(class = "text-muted small mb-0", "Consultez les profils et programmes")
                    )
                  )
                ),
                div(class = "col-md-4 mb-3",
                  div(class = "d-flex align-items-center",
                    div(class = "me-3 text-center", style = "width: 40px; height: 40px; background-color: #e9ecef; border-radius: 50%; line-height: 40px;",
                      span("3", class = "fw-bold")
                    ),
                    div(
                      h5("Votez", class = "mb-1"),
                      p(class = "text-muted small mb-0", "Cliquez sur le bouton pour confirmer")
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  ),
  
  # JavaScript output for vote progress updates
  uiOutput("vote_js"),
  
  # Style CSS pour la page de vote
  tags$style(HTML("
    .vote-container {
      padding-bottom: 40px;
    }
    
    .vote-banner {
      background: linear-gradient(135deg, #2c3e50, #3498db);
      transition: all 0.3s ease;
    }
    
    .vote-banner:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
    }
    
    .border-left-primary {
      border-left: 4px solid #dee2e6 !important;
    }
    
    .border-left-success {
      border-left: 4px solid #dee2e6 !important;
    }
    
    .border-left-info {
      border-left: 4px solid #dee2e6 !important;
    }
    
    .card {
      transition: all 0.3s ease;
      margin-bottom: 1.5rem;
    }
    
    .card:hover {
      transform: translateY(-5px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.1) !important;
    }
    
    .position-button {
      transition: all 0.2s ease;
      margin-bottom: 8px;
    }
    
    .position-button:hover {
      transform: translateX(5px);
    }
    
    .candidate-card {
      transition: all 0.3s ease;
      border-radius: 8px;
      overflow: hidden;
    }
    
    .candidate-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.1) !important;
    }
    
    /* Animation pour les boutons de vote */
    @keyframes pulse {
      0% { transform: scale(1); }
      50% { transform: scale(1.05); }
      100% { transform: scale(1); }
    }
    
    .btn-vote {
      animation: pulse 2s infinite;
    }
    
    /* Style pour le statut de vote */
    .vote-status {
      padding: 8px 12px;
      border-radius: 4px;
      font-weight: 500;
    }
    
    .vote-pending {
      background-color: rgba(63, 81, 181, 0.1);
      color: #3f51b5;
    }
    
    .vote-completed {
      background-color: rgba(63, 81, 181, 0.2);
      color: #303f9f;
    }
    
    /* Masquer les barres de défilement */
    .position-checkboxes::-webkit-scrollbar,
    .position-buttons-container::-webkit-scrollbar {
      width: 0 !important;
      display: none !important;
    }
    
    .position-buttons-container {
      -ms-overflow-style: none !important;
      scrollbar-width: none !important;
    }
  "))
) 
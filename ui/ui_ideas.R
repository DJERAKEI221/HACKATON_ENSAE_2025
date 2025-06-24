div(class = "container ideas-container",
  # CSS stylesheet
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/ideas.css")
  ),
  
  # JavaScript pour le centrage des éléments
  tags$script(HTML("
    $(document).ready(function() {
      // Assurer que les conteneurs sont bien centrés
      $('.ideas-container').css({
        'max-width': '1200px',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'width': '100%'
      });
      
      // Assurer que les bannières prennent toute la largeur
      $('.ideas-banner').css('width', '100%');
      
      // Assurer que les rangées et colonnes sont correctement dimensionnées
      $('.row').css('width', '100%');
      $('.col-lg-5, .col-lg-7, .col-md-4, .col-12').css({
        'padding-right': '15px',
        'padding-left': '15px'
      });
      
      // Amélioration de l'affichage des cartes
      $('.card').css({
        'width': '100%',
        'margin-bottom': '20px'
      });
    });
  ")),
  
  div(class = "spacer", style = "height: 10px;"),
  
  # Banner attractif pour la boîte à idées
  div(class = "ideas-banner mb-4 mt-4 text-center bg-info text-white p-4 rounded shadow",
    div(class = "row align-items-center",
      div(class = "col-md-2 text-center d-none d-md-block", 
        icon("lightbulb", class = "fa-3x mb-2")
      ),
      div(class = "col-md-8",
        h2("Partagez vos idées", class = "mb-2"),
        p(class = "lead mb-0", "Ensemble, améliorons le processus électoral de l'ENSAE")
      ),
      div(class = "col-md-2 text-center d-none d-md-block", 
        icon("comments", class = "fa-3x mb-2")
      )
    )
  ),
  
  # Section principale avec 2 colonnes
  div(class = "row",
    # Colonne gauche - Formulaire de soumission
    div(class = "col-lg-5 mb-4",
      bslib::card(class = "shadow-sm h-100 border-primary", style = "border-left: 4px solid #dee2e6;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center", 
            icon("edit", class = "me-2 text-primary"),
            h3("Proposer une idée", class = "mb-0 fs-4")
          )
        ),
        bslib::card_body(
          p(class = "text-muted", "Votre suggestion pourrait améliorer les futures élections !"),
          
          # Avatar et catégorie côte à côte
          div(class = "row mb-3 align-items-center",
            div(class = "col-md-3 text-center",
              div(class = "avatar-circle mx-auto",
                icon("user-graduate", class = "fa-2x text-white")
              )
            ),
            div(class = "col-md-9",
              div(class = "form-group",
                tags$label(class = "form-label", "Catégorie"),
                div(class = "input-group",
                  div(class = "input-group-prepend",
                    tags$span(class = "input-group-text", icon("tag"))
                  ),
                  selectInput("idea_category", NULL, 
                    choices = c(
                      "Interface de vote" = "interface",
                      "Organisation des élections" = "organisation",
                      "Présentation des candidats" = "candidats",
                      "Processus électoral" = "processus",
                      "Autre suggestion" = "autre"
                    ),
                    width = "100%"
                  )
                )
              )
            )
          ),
          
          # Zone de texte améliorée
          div(class = "form-group mb-4",
            tags$label(class = "form-label", "Votre suggestion"),
            div(class = "idea-textarea-container",
              textAreaInput("idea_text", NULL, 
                placeholder = "Décrivez votre idée pour améliorer les futures élections...",
                height = "150px",
                resize = "vertical"
              )
            )
          ),
          
          # Options supplémentaires et bouton de soumission
          div(class = "row",
            div(class = "col-md-6",
              div(class = "form-check mb-3",
                tags$input(type = "checkbox", id = "anonymous_idea", class = "form-check-input"),
                tags$label(class = "form-check-label", `for` = "anonymous_idea", "Rester anonyme")
              )
            ),
            div(class = "col-md-6 text-end",
              actionButton("submit_idea", "Soumettre", 
                          class = "btn btn-primary btn-lg", 
                          icon = icon("paper-plane"))
            )
          )
        )
      )
    ),
    
    # Colonne droite - Affichage des idées
    div(class = "col-lg-7",
      bslib::card(class = "shadow-sm border-success", style = "border-left: 4px solid #28a745;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center justify-content-between", 
            div(class = "d-flex align-items-center",
              icon("list-ul", class = "me-2 text-success"),
              h3("Suggestions de la communauté", class = "mb-0 fs-4")
            ),
            div(class = "d-flex",
              selectInput("filter_ideas", NULL, 
                choices = c(
                  "Toutes les suggestions" = "all",
                  "Interface de vote" = "interface",
                  "Organisation des élections" = "organisation",
                  "Présentation des candidats" = "candidats",
                  "Processus électoral" = "processus",
                  "Autre suggestion" = "autre"
                ),
                width = "180px"
              )
            )
          )
        ),
        bslib::card_body(
          div(class = "ideas-list-container", 
            uiOutput("ideas_list")
          )
        ),
        bslib::card_footer(class = "bg-light d-flex justify-content-between align-items-center",
          div(class = "text-muted small", 
            icon("info-circle", class = "me-1"),
            "Les suggestions sont modérées avant publication"
          ),
          actionButton("refresh_ideas", "Actualiser", 
                      class = "btn btn-sm btn-outline-secondary", 
                      icon = icon("sync"))
        )
      )
    )
  ),
  
  # Section d'inspiration
  div(class = "row mt-4",
    div(class = "col-12",
      bslib::card(class = "shadow-sm border-warning", style = "border-left: 4px solid #dee2e6;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center", 
            icon("star", class = "me-2 text-warning"),
            h4("Idées populaires", class = "mb-0")
          )
        ),
        bslib::card_body(
          uiOutput("popular_ideas")
        )
      )
    )
  ),
  
  # Styles CSS pour la page suggestions
  tags$style(HTML("
    .ideas-container {
      padding-bottom: 40px;
    }
    
    .ideas-banner {
      background: linear-gradient(135deg, #17a2b8, #20c997);
      transition: all 0.3s ease;
    }
    
    .ideas-banner:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
    }
    
    .avatar-circle {
      width: 60px;
      height: 60px;
      background-color: #007bff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .idea-textarea-container {
      background-color: #f8f9fa;
      border-radius: 8px;
      padding: 2px;
      transition: all 0.3s ease;
    }
    
    .idea-textarea-container:focus-within {
      background-color: #e9f8fb;
      box-shadow: 0 0 0 0.2rem rgba(23, 162, 184, 0.25);
    }
    
    #idea_text {
      border: 1px solid #ced4da;
      border-radius: 6px;
      transition: all 0.3s ease;
    }
    
    .popular-idea {
      background-color: #fff;
      border-radius: 8px;
      transition: all 0.3s ease;
    }
    
    .popular-idea:hover {
      transform: translateY(-5px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.1) !important;
    }
    
    /* Style pour les suggestions dans la liste */
    .idea-card {
      border-left: 4px solid #dee2e6;
      margin-bottom: 15px;
      transition: all 0.3s ease;
    }
    
    .idea-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.08) !important;
    }
    
    .idea-card.interface { border-left-color: #dee2e6; }
    .idea-card.organisation { border-left-color: #dee2e6; }
    .idea-card.candidats { border-left-color: #dee2e6; }
    .idea-card.processus { border-left-color: #dee2e6; }
    .idea-card.autre { border-left-color: #dee2e6; }
    
    .idea-meta {
      font-size: 0.85rem;
      color: #6c757d;
    }
    
    .idea-category {
      font-size: 0.75rem;
      padding: 3px 8px;
      border-radius: 12px;
    }
    
    .btn-primary {
      position: relative;
      overflow: hidden;
      transition: all 0.3s ease;
    }
    
    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 5px 15px rgba(0, 123, 255, 0.3);
    }
    
    .btn-primary:active {
      transform: translateY(1px);
    }
  "))
) 
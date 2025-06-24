fluidPage(
  div(class = "container-fluid stats-container",
    # CSS stylesheet
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/stats.css")
    ),

    # JavaScript pour le centrage des éléments
    tags$script(HTML("
      $(document).ready(function() {
        // Assurer que les conteneurs sont bien centrés
        $('.stats-container').css({
          'max-width': '1200px',
          'margin-left': 'auto',
          'margin-right': 'auto',
          'width': '100%'
        });
        
        // Assurer que les bannières prennent toute la largeur
        $('.stats-banner').css('width', '100%');
        
        // Assurer que les rangées et colonnes sont correctement dimensionnées
        $('.row').css('width', '100%');
        $('.col-3, .col-6, .col-12').css({
          'padding-right': '15px',
          'padding-left': '15px'
        });
        
        // Amélioration de l'affichage des cartes et compteurs
        $('.card, .counter-card').css({
          'width': '100%',
          'margin-bottom': '20px'
        });
        
        // Amélioration de l'affichage des graphiques
        $('.chart-container').css('width', '100%');
        
        // Appliquer les styles lors du redimensionnement de la fenêtre
        $(window).resize(function() {
          $('.stats-container, .stats-banner, .row, .card, .counter-card, .chart-container').css('width', '100%');
        });
      });
    ")),

    div(class = "spacer", style = "height: 10px;"),
    
    # Banner attractif pour la page statistiques
    div(class = "stats-banner mb-4 mt-4 text-center bg-primary text-white p-4 rounded shadow",
      style = "background-color: #3f51b5 !important;",
      div(class = "row align-items-center",
        div(class = "col-md-2 text-center d-none d-md-block", 
          icon("chart-bar", class = "fa-3x mb-2 text-white")
        ),
        div(class = "col-md-8",
          h2("Tableau de bord électoral", class = "mb-2", style = "color: white !important;"),
          p(class = "lead mb-0", style = "color: white !important;", "Suivi en temps réel de la participation et des tendances du vote")
        ),
        div(class = "col-md-2 text-center d-none d-md-block", 
          icon("magnifying-glass-chart", class = "fa-3x mb-2 text-white")
        )
      )
    ),
    
    # Compteurs récapitulatifs
    fluidRow(class = "mb-4 stats-counters",
      column(6,
        div(class = "counter-card bg-white shadow-sm rounded p-3 h-100 border-left-primary",
          div(class = "d-flex align-items-center",
            div(class = "counter-icon rounded-circle bg-primary-light me-3",
              icon("check-to-slot", class = "fa-2x text-primary")
            ),
            div(class = "counter-content",
              h3(class = "counter-value mb-0", textOutput("total_votes")),
              p(class = "counter-label text-muted mb-0", HTML("<span style='font-size: 1.2rem; color: blue; font-weight: bold;'>Votes enregistrés</span>"))
            )
          )
        )
      ),
      column(6,
        div(class = "counter-card bg-white shadow-sm rounded p-3 h-100 border-left-warning",
          div(class = "d-flex align-items-center",
            div(class = "counter-icon rounded-circle bg-warning-light me-3",
              icon("person-booth", class = "fa-2x text-warning")
            ),
            div(class = "counter-content",
              h3(class = "counter-value mb-0", textOutput("contested_positions")),
              p(class = "counter-label text-muted mb-0", HTML("<span style='font-size: 1.2rem; color: blue; font-weight: bold;'>Postes disputés</span>"))
            )
          )
        )
      )
    ),
    
    # Graphiques
    fluidRow(
      # Participation globale (remplacé par des cartes)
      column(6,
        bslib::card(class = "shadow-sm border-primary", style = "border-left: 4px solid #0d6efd; height: 200px;",
          bslib::card_header(class = "bg-light py-1",
            div(class = "d-flex align-items-center",
              icon("chart-pie", class = "me-2 text-primary"),
              h4("Participation globale", class = "mb-0", style = "font-size: 1.1rem;")
            )
          ),
          bslib::card_body(
            div(class = "row h-100",
              # Carte pour les votes enregistrés
              div(class = "col-6 h-100 d-flex align-items-center justify-content-center",
                div(class = "text-center",
                  h3(class = "mb-0", style = "color: #27ae60; font-weight: bold; font-size: 1.8rem;", textOutput("voted_rate")),
                  p(class = "mb-0", style = "color: #666; font-size: 1rem; font-weight: bold;", "Ont voté")
                )
              ),
              # Carte pour les non-votants
              div(class = "col-6 h-100 d-flex align-items-center justify-content-center",
                div(class = "text-center",
                  h3(class = "mb-0", style = "color: #e74c3c; font-weight: bold; font-size: 1.8rem;", textOutput("not_voted_rate")),
                  p(class = "mb-0", style = "color: #666; font-size: 1rem; font-weight: bold;", "N'ont pas voté")
                )
              )
            )
          )
        )
      ),
      # Graphique de participation par classe
      column(6,
        bslib::card(class = "shadow-sm border-primary", style = "border-left: 4px solid #0d6efd; height: 200px;",
          bslib::card_header(class = "bg-light py-1",
            div(class = "d-flex align-items-center justify-content-between",
              div(class = "d-flex align-items-center",
                icon("chart-bar", class = "me-2 text-primary"),
                h4("Participation par classe", class = "mb-0", style = "font-size: 1.1rem;")
              ),
              div(style = "z-index: 1000;",  # Assure que le filtre est au premier plan
                selectInput("class_filter", NULL,
                  choices = list(
                    "AS1" = "as1",
                    "AS2" = "as2",
                    "AS3" = "as3",
                    "ISEP1" = "isep1",
                    "ISEP2" = "isep2",
                    "ISEP3" = "isep3",
                    "ISE1 Maths" = "ise1_maths",
                    "ISE1 Eco" = "ise1_eco",
                    "ISE2" = "ise2",
                    "ISE3" = "ise3",
                    "Master stats agricoles" = "master_stats_agricoles",
                    "Master ADEP" = "master_adep"
                  ),
                  selected = "as1",
                  width = "200px"
                )
              )
            )
          ),
          bslib::card_body(
            div(class = "row h-100",
              # Carte pour les votes enregistrés
              div(class = "col-6 h-100 d-flex align-items-center justify-content-center",
                div(class = "text-center",
                  h3(class = "mb-0", style = "color: #27ae60; font-weight: bold; font-size: 1.8rem;", textOutput("class_voted_rate")),
                  p(class = "mb-0", style = "color: #666; font-size: 1rem; font-weight: bold;", "Ont voté")
                )
              ),
              # Carte pour les non-votants
              div(class = "col-6 h-100 d-flex align-items-center justify-content-center",
                div(class = "text-center",
                  h3(class = "mb-0", style = "color: #e74c3c; font-weight: bold; font-size: 1.8rem;", textOutput("class_not_voted_rate")),
                  p(class = "mb-0", style = "color: #666; font-size: 1rem; font-weight: bold;", "N'ont pas voté")
                )
              )
            )
          )
        )
      )
    ),
    
    # Graphique d'activité de vote
    fluidRow(class = "mt-4",
      column(12,
        bslib::card(class = "shadow-sm border-primary", style = "border-left: 4px solid #0d6efd;",
          bslib::card_header(class = "bg-light",
            div(class = "d-flex align-items-center",
              icon("chart-line", class = "me-2 text-primary"),
              h4("Activité de vote", class = "mb-0")
            )
          ),
          bslib::card_body(
            plotOutput("vote_timeline", height = "300px")
          )
        )
      )
    ),
    
    # Tableau de bord électoral
    fluidRow(class = "mt-4",
      column(12,
        bslib::card(class = "shadow-sm border-primary", style = "border-left: 4px solid #0d6efd;",
          bslib::card_header(class = "bg-light",
            div(class = "d-flex align-items-center justify-content-between",
              div(class = "d-flex align-items-center")
            )
          ),
          bslib::card_body(
            uiOutput("election_dashboard")
          )
        )
      )
    )
  )
) 
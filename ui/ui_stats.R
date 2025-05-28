div(class = "container stats-container",
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
    column(3,
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
    column(3,
      div(class = "counter-card bg-white shadow-sm rounded p-3 h-100 border-left-success",
        div(class = "d-flex align-items-center",
          div(class = "counter-icon rounded-circle bg-success-light me-3",
            icon("percent", class = "fa-2x text-success")
          ),
          div(class = "counter-content",
            h3(class = "counter-value mb-0", textOutput("participation_rate")),
            p(class = "counter-label text-muted mb-0", HTML("<span style='font-size: 1.2rem; color: blue; font-weight: bold;'>Taux de participation</span>"))
          )
        )
      )
    ),
    column(3,
      div(class = "counter-card bg-white shadow-sm rounded p-3 h-100 border-left-info",
        div(class = "d-flex align-items-center",
          div(class = "counter-icon rounded-circle bg-info-light me-3",
            icon("user-graduate", class = "fa-2x text-info")
          ),
          div(class = "counter-content",
            h3(class = "counter-value mb-0", textOutput("active_voters")),
            p(class = "counter-label text-muted mb-0", HTML("<span style='font-size: 1.2rem; color: blue; font-weight: bold;'>Électeurs actifs</span>"))
          )
        )
      )
    ),
    column(3,
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
  
  # Graphiques de participation
  fluidRow(class = "mb-4",
    column(6,
      bslib::card(class = "shadow-sm border-primary h-100", style = "border-left: 4px solid #007bff;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center justify-content-between", 
            div(class = "d-flex align-items-center",
              icon("chart-pie", class = "me-2 text-primary"),
              h4("Participation globale", class = "mb-0")
            ),
            div(class = "btn-group",
              actionButton("refresh_global", "Actualiser", class = "btn btn-sm btn-outline-primary", icon = icon("sync")),
              downloadButton("download_global_chart", "", class = "btn btn-sm btn-outline-primary")
            )
          )
        ),
        bslib::card_body(
          div(class = "chart-container", style = "position: relative; height: 300px;",
            plotOutput("participation_chart")
          )
        ),
        bslib::card_footer(class = "bg-light",
          div(class = "d-flex justify-content-between align-items-center",
            div(class = "small text-muted", "Mise à jour automatique toutes les 5 minutes"),
            div(class = "stat-summary small fw-bold", textOutput("global_summary"))
          )
        )
      )
    ),
    column(6,
      bslib::card(class = "shadow-sm border-success h-100", style = "border-left: 4px solid #28a745;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center justify-content-between", 
            div(class = "d-flex align-items-center",
              icon("users-between-lines", class = "me-2 text-success"),
              h4("Participation par classe", class = "mb-0")
            ),
            div(class = "participation-filter",
              selectInput("class_filter", NULL, 
                choices = c("Toutes les classes" = "all", "AS" = "as", "ISEP" = "isep", "ISE" = "ise", "Masters" = "masters"),
                selected = "all",
                width = "150px"
              )
            )
          )
        ),
        bslib::card_body(
          div(class = "chart-container", style = "position: relative; height: 300px;",
            plotOutput("participation_by_year")
          )
        ),
        bslib::card_footer(class = "bg-light",
          div(class = "d-flex justify-content-between align-items-center",
            div(class = "small text-muted", textOutput("highest_class")),
            div(class = "stat-summary small fw-bold", textOutput("class_summary"))
          )
        )
      )
    )
  ),
  
  # Graphique d'activité électorale temporelle
  fluidRow(class = "mb-4",
    column(12,
      bslib::card(class = "shadow-sm border-info", style = "border-left: 4px solid #dee2e6;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center justify-content-between", 
            div(class = "d-flex align-items-center",
              icon("chart-line", class = "me-2 text-info"),
              h4("Évolution de la participation", class = "mb-0")
            ),
            div(class = "d-flex align-items-center",
              div(class = "date-range-selector me-2",
                selectInput("timeline_range", NULL, 
                  choices = c("Dernières 24h" = "24h", "3 derniers jours" = "3d", "Semaine" = "1w", "Tout" = "all"),
                  selected = "24h",
                  width = "140px"
                )
              ),
              downloadButton("downloadStats", "Rapport complet", class = "btn-sm btn-info")
            )
          )
        ),
        bslib::card_body(
          div(class = "chart-container", style = "position: relative; height: 350px;",
            plotOutput("vote_timeline")
          )
        ),
        bslib::card_footer(class = "bg-light",
          div(class = "row align-items-center",
            div(class = "col-md-4 border-end",
              div(class = "d-flex align-items-center",
                icon("clock", class = "me-2 text-info"),
                div(
                  p(class = "mb-0 small", "Pic d'activité"),
                  p(class = "mb-0 fw-bold", textOutput("peak_time"))
                )
              )
            ),
            div(class = "col-md-4 border-end",
              div(class = "d-flex align-items-center",
                icon("arrow-trend-up", class = "me-2 text-success"),
                div(
                  p(class = "mb-0 small", "Tendance actuelle"),
                  p(class = "mb-0 fw-bold", textOutput("current_trend"))
                )
              )
            ),
            div(class = "col-md-4",
              div(class = "d-flex align-items-center",
                icon("hourglass-half", class = "me-2 text-warning"),
                div(
                  p(class = "mb-0 small", "Temps restant"),
                  p(class = "mb-0 fw-bold", textOutput("remaining_time"))
                )
              )
            )
          )
        )
      )
    )
  ),
  
  # Tableau détaillé
  fluidRow(
    column(12,
      bslib::card(class = "shadow-sm border-warning", style = "border-left: 4px solid #ffc107;",
        bslib::card_header(class = "bg-light",
          div(class = "d-flex align-items-center justify-content-between", 
            div(class = "d-flex align-items-center",
              icon("table-list", class = "me-2 text-warning"),
              h4("Détails par poste électoral", class = "mb-0")
            ),
            div(class = "d-flex",
              div(class = "position-search me-2",
                div(class = "input-group",
                  div(class = "input-group-text bg-white border-end-0",
                    icon("search", class = "text-muted")
                  ),
                  tags$input(type = "text", id = "position_search", class = "form-control border-start-0", 
                            placeholder = "Rechercher un poste")
                )
              ),
              downloadButton("download_csv", "Exporter CSV", class = "btn-sm btn-outline-warning")
            )
          )
        ),
        bslib::card_body(
          div(class = "table-responsive",
            DTOutput("participation_table")
          )
        ),
        bslib::card_footer(class = "bg-light text-center",
          actionButton("print_stats", "Imprimer les statistiques", 
                      class = "btn btn-secondary", 
                      icon = icon("print"))
        )
      )
    )
  ),
  
  # Styles CSS pour la page statistiques
  tags$style(HTML("
    .stats-container {
      padding-bottom: 40px;
    }
    
    .stats-banner {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white !important;
      transition: all 0.3s ease;
    }
    
    .stats-banner:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
    }
    
    .chart-container {
      transition: all 0.3s ease;
    }
    
    .chart-container:hover {
      transform: translateY(-3px);
    }
    
    /* Styles pour les cartes de compteurs */
    .counter-card {
      transition: all 0.3s ease;
      border-left-width: 4px;
      border-left-style: solid;
    }
    
    .counter-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.08) !important;
    }
    
    .counter-icon {
      width: 60px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .counter-value {
      font-size: 1.8rem;
      font-weight: 700;
    }
    
    .counter-label {
      font-size: 0.85rem;
    }
    
    /* Couleurs de fond pour les icônes */
    .bg-primary-light { background-color: rgba(63, 81, 181, 0.1); }
    .bg-success-light { background-color: rgba(63, 81, 181, 0.1); }
    .bg-info-light { background-color: rgba(63, 81, 181, 0.1); }
    .bg-warning-light { background-color: rgba(63, 81, 181, 0.1); }
    
    /* Styles de bordures gauches */
    .border-left-primary { border-left-color: #dee2e6; }
    .border-left-success { border-left-color: #dee2e6; }
    .border-left-info { border-left-color: #dee2e6; }
    .border-left-warning { border-left-color: #dee2e6; }
    
    /* Animation pour les chiffres */
    @keyframes countUp {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .counter-value {
      animation: countUp 1s ease-out forwards;
    }
    
    /* Style des tableaux */
    .dataTables_wrapper {
      padding: 0;
    }
    
    table.dataTable {
      border-collapse: collapse !important;
    }
    
    table.dataTable thead th {
      background-color: #f8f9fa;
      border-bottom: 2px solid #dee2e6 !important;
    }
    
    table.dataTable tbody tr:hover {
      background-color: rgba(0,0,0,0.01);
    }
    
    /* Responsive design ajustements */
    @media (max-width: 768px) {
      .counter-card {
        margin-bottom: 15px;
      }
      
      .counter-icon {
        width: 50px;
        height: 50px;
      }
      
      .counter-value {
        font-size: 1.5rem;
      }
    }
  "))
) 
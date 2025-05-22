# Interface principale avec la navbar

fluidPage(
  useShinyjs(), # Pour les manipulations DOM dynamiques
  
  # Interface d'authentification (s'affiche au-dessus de tout)
  uiOutput("auth_screen"),
  
  # Application principale
  bslib::page_navbar(
    title = div(
      div(class = "header-container",
        div(class = "logo-container",
          img(src = "images/ensae.png", class = "header-logo")
        )
      ),
      class = "navbar-brand-enhanced"
    ),
    window_title = "Élections ENSAE 2025",
    id = "main_navbar",
    navbar_options = bslib::navbar_options(
      position = "fixed-top",
      collapsible = TRUE
    ),
    theme = bslib::bs_theme(
      version = 5,
      bootswatch = "flatly",
      base_font = font_google("Roboto"),
      heading_font = font_google("Poppins"),
      "nav-tab-font-size" = "1.1rem",
      "nav-link-padding-y" = "1.5rem",
      "navbar-padding-y" = "0.5rem"
    ),
    header = tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
      tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"),
      tags$script(src = "js/mobile.js"),
      # Styles simplifiés pour garantir l'alignement horizontal
      tags$style(HTML("
        /* Styles de base pour la navbar */
        .navbar {
          background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
          height: 90px;
          z-index: 1030 !important;
        }
        
        /* Logo */
        .logo-container {
          background: white;
          border-radius: 12px;
          width: 70px;
          height: 70px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 3px solid white;
        }
        
        .header-logo {
          height: 56px;
          width: 56px;
        }
        
        /* Alignement horizontal forcé */
        .nav, .navbar-nav {
          display: flex !important;
          flex-direction: row !important;
          justify-content: center !important;
          align-items: center !important;
          width: 100% !important;
          overflow: visible !important;
        }
        
        /* Style des onglets */
        .nav-item {
          float: left !important;
          display: inline-block !important;
          margin: 0 2px !important;
        }
        
        .nav-link {
          color: white !important;
          font-weight: 500 !important;
          padding: 20px 8px !important;
          text-align: center !important;
          float: none !important;
          display: inline-block !important;
          font-size: 0.95rem !important;
        }
        
        .nav-link:hover, .nav-link.active {
          color: white !important;
          background-color: rgba(255, 255, 255, 0.15) !important;
        }
        
        /* Positionnement général */
        .container-fluid {
          display: flex !important;
          justify-content: center !important;
          align-items: center !important;
          width: 100% !important;
        }
        
        .navbar-collapse {
          display: flex !important;
          justify-content: center !important;
          align-items: center !important;
          width: 100% !important;
        }
        
        /* Mobile */
        @media (max-width: 991px) {
          .nav, .navbar-nav {
            flex-direction: column !important;
          }
          
          .navbar {
            height: auto !important;
            min-height: 110px !important;
          }
        }
        
        /* S'assurer que le contenu des pages est visible */
        .tab-content {
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
          padding-top: 30px !important;
          min-height: 80vh !important;
        }
        
        .tab-pane {
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
        }
        
        .tab-pane.active {
          display: block !important;
        }
        
        .tab-pane:not(.active) {
          display: none !important;
        }
      ")),
      
      # JavaScript minimaliste
      tags$script(HTML("
        $(document).ready(function() {
          // Forcer l'alignement horizontal
          $('.navbar-nav, .nav').css({
            'display': 'flex',
            'flex-direction': 'row',
            'justify-content': 'center',
            'align-items': 'center',
            'width': '100%'
          });
          
          $('.nav-item').css({
            'float': 'left',
            'display': 'inline-block',
            'margin': '0 2px'
          });
          
          $('.nav-link').css({
            'display': 'inline-block',
            'padding': '20px 8px',
            'font-size': '0.95rem'
          });
          
          // Supprimer les classes qui interfèrent
          $('.navbar-collapse').removeClass('collapse');
          $('.navbar-nav').removeClass('flex-column');
          
          // S'assurer que le contenu est visible
          $('.tab-content').css({
            'display': 'block',
            'visibility': 'visible',
            'padding-top': '30px',
            'min-height': '80vh'
          });
          
          // Gérer correctement l'affichage des onglets
          $('.nav-link').on('click', function(e) {
            // Récupérer l'ID du panneau cible
            var targetId = $(this).attr('data-bs-target') || $(this).attr('href');
            
            // Masquer tous les panneaux
            $('.tab-pane').removeClass('active').hide();
            
            // Afficher le panneau cible
            $(targetId).addClass('active').show();
            
            // Garder la classe active sur l'onglet
            $('.nav-link').removeClass('active');
            $(this).addClass('active');
          });
          
          // Activer l'onglet initial (soit basé sur l'URL, soit le premier)
          var initialTab = window.location.hash || $('.nav-link').first().attr('href');
          if (initialTab) {
            $('a[href=\"' + initialTab + '\"]').click();
          } else {
            $('.nav-link').first().click();
          }
        });
      "))
    ),
    
    # Panneaux et onglets avec attributs inline
    bslib::nav_panel("Accueil", icon = icon("home"), style = "display: inline-block; float: left;",
      source("ui/ui_home.R")$value
    ),
    
    # Panneau des délégués de classe
    bslib::nav_panel("Délégués de Classe", icon = icon("user-graduate"), style = "display: inline-block; float: left;",
                     source("ui/ui_delegates.R")$value
    ),
    
    # Panneau des candidats
    bslib::nav_panel("Candidats", icon = icon("user-tie"), style = "display: inline-block; float: left;", 
      source("ui/ui_candidates.R")$value
    ),
    
    # Panneau de vote avec onglets dynamiques par poste
    bslib::nav_panel("Vote", icon = icon("check-to-slot"), style = "display: inline-block; float: left;",
      source("ui/ui_vote.R")$value
    ),
    
    # Panneau des statistiques avancées
    bslib::nav_panel("Statistiques", icon = icon("chart-pie"), style = "display: inline-block; float: left;",
                     source("ui/ui_stats.R")$value
    ),
    
    # Panneau des résultats
    bslib::nav_panel("Résultats", icon = icon("chart-column"), style = "display: inline-block; float: left;",
      source("ui/ui_results.R")$value
    ),
    
    # Panneau de boîte à idées
    bslib::nav_panel("Boîte à Idées", icon = icon("lightbulb"), style = "display: inline-block; float: left;",
      source("ui/ui_ideas.R")$value
    )
  )
) 
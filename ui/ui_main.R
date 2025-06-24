# Interface principale avec la navbar

tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css")
)

fluidPage(
  useShinyjs(), # Pour les manipulations DOM dynamiques
  
  # Module de notifications en temps réel
  notificationUI("notifications"),
  
  # Module de gamification (affichage des points XP, notifications)
  gamificationUI("gamification"),
  
  # Interface d'authentification (module UI)
  uiOutput("auth-auth_screen_ui"),
  
  # Application principale
  bslib::page_navbar(
    title = "",
    window_title = "Élections ENSAE 2025",
    id = "main_navbar",
    position = "fixed-top",
    collapsible = TRUE,
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
      tags$link(rel = "stylesheet", type = "text/css", href = "css/fix-alignment.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/navbar-compact.css"),
      tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"),
      tags$script(src = "js/mobile.js"),
      tags$script(src = "js/confetti/confetti.min.js"),
      tags$script(src = "js/center-elements.js"),
      tags$script(src = "js/stats.js"),
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
          float: none !important;
        }
        
        /* Correction pour l'alignement du contenu principal */
        .container, 
        .home-container, 
        .delegates-container, 
        .candidates-container, 
        .vote-container, 
        .stats-container, 
        .results-container, 
        .ideas-container {
          margin-left: auto !important;
          margin-right: auto !important;
          float: none !important;
          display: block !important;
          text-align: left !important;
          position: relative !important;
        }
        
        /* Forcer une largeur stable sur les colonnes */
        .row {
          width: 100% !important;
          margin-left: 0 !important;
          margin-right: 0 !important;
          float: none !important;
          display: flex !important;
          flex-wrap: wrap !important;
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
        
        /* Bouton Haut de page */
        .scroll-to-top-btn {
          position: fixed !important;
          bottom: 20px !important;
          left: 20px !important;
          background: linear-gradient(135deg, #3f51b5, #303f9f);
          color: white;
          border: none;
          border-radius: 50px;
          padding: 15px 20px;
          cursor: pointer;
          box-shadow: 0 4px 20px rgba(63, 81, 181, 0.3);
          transition: all 0.3s ease;
          z-index: 9998 !important;
          display: none;
          align-items: center;
          gap: 8px;
          font-weight: 500;
          font-size: 0.9rem;
          max-width: 150px;
          user-select: none;
        }
        
        .scroll-to-top-btn:hover {
          background: linear-gradient(135deg, #303f9f, #1a237e);
          transform: translateY(-3px);
          box-shadow: 0 6px 25px rgba(63, 81, 181, 0.4);
        }
        
        .scroll-to-top-btn.show {
          display: flex !important;
        }
        
        .scroll-to-top-btn i {
          font-size: 1.1rem;
        }
        
        .scroll-to-top-btn .btn-text {
          font-size: 0.85rem;
          white-space: nowrap;
        }
        
        /* Version mobile du bouton */
        @media (max-width: 768px) {
          .scroll-to-top-btn {
            bottom: 15px !important;
            right: 15px !important;
            padding: 12px 16px;
            max-width: 120px;
          }
          
          .scroll-to-top-btn .btn-text {
            font-size: 0.75rem;
          }
          
          .scroll-to-top-btn i {
            font-size: 1rem;
          }
        }
        
        /* Bouton thème dans la navbar */
        .theme-dropdown {
          margin-right: 15px;
        }
        
        .theme-btn {
          background: rgba(255, 255, 255, 0.1) !important;
          border: 1px solid rgba(255, 255, 255, 0.2) !important;
          border-radius: 8px !important;
          color: white !important;
          padding: 8px 12px !important;
          transition: all 0.3s ease !important;
          display: flex !important;
          align-items: center !important;
          justify-content: center !important;
          width: 44px !important;
          height: 44px !important;
        }
        
        .theme-btn:hover, .theme-btn:focus, .theme-btn.show {
          background: rgba(255, 255, 255, 0.2) !important;
          border-color: rgba(255, 255, 255, 0.3) !important;
          color: white !important;
          transform: scale(1.05) !important;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15) !important;
        }
        
        .theme-btn i {
          font-size: 1.1rem !important;
        }
        
        .theme-menu {
          border: none !important;
          border-radius: 12px !important;
          box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
          padding: 8px 0 !important;
          min-width: 200px !important;
          margin-top: 8px !important;
          background: white !important;
        }
        
        .theme-menu .dropdown-header {
          font-weight: 600 !important;
          color: #3f51b5 !important;
          padding: 10px 20px !important;
          font-size: 0.9rem !important;
        }
        
        .theme-menu .dropdown-item {
          padding: 12px 20px !important;
          transition: all 0.2s ease !important;
          border-radius: 0 !important;
          color: #333 !important;
        }
        
        .theme-menu .dropdown-item:hover {
          background: linear-gradient(135deg, rgba(63, 81, 181, 0.1), rgba(63, 81, 181, 0.05)) !important;
          color: #3f51b5 !important;
          padding-left: 25px !important;
        }
        
        .theme-menu .dropdown-item i {
          width: 16px !important;
          color: #666 !important;
        }
        
        .theme-menu .dropdown-item:hover i {
          color: #3f51b5 !important;
        }
        
        .theme-menu .dropdown-item.active {
          background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
          color: white !important;
        }
        
        .theme-menu .dropdown-item.active i {
          color: white !important;
        }
        
        .theme-menu .dropdown-item.active:hover {
          background: linear-gradient(135deg, #303f9f, #1a237e) !important;
          color: white !important;
          padding-left: 20px !important;
        }
        
        /* Responsive pour le bouton thème */
        @media (max-width: 768px) {
          .theme-dropdown {
            margin-right: 10px;
          }
          
          .theme-btn {
            width: 38px !important;
            height: 38px !important;
            padding: 6px 8px !important;
          }
          
          .theme-btn i {
            font-size: 1rem !important;
          }
        }
        
        /* Décalage des onglets vers la droite */
        .navbar-nav {
          margin-left: 100px !important;
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
          
          // Gestion du bouton Haut de page
          initScrollToTopButton();
          
          // Charger le thème sauvegardé
          loadSavedTheme();
        });
        
        // Variable globale pour le statut d'administrateur
        window.user_is_admin = false;
        
        // Gestionnaire pour mettre à jour le statut d'administrateur
        Shiny.addCustomMessageHandler('updateAdminStatus', function(message) {
          window.user_is_admin = message.isAdmin;
          
          // Mettre à jour l'affichage des éléments admin
          if (message.isAdmin) {
            $('.admin-only').show();
            $('input[name=\"user_is_admin\"]').val('true');
          } else {
            $('.admin-only').hide();
            $('input[name=\"user_is_admin\"]').val('false');
          }
        });
        
        // Gestionnaires pour les messages personnalisés des notifications
        Shiny.addCustomMessageHandler('showAnnouncementBanner', function(message) {
          if (typeof window.showAnnouncementBanner === 'function') {
            window.showAnnouncementBanner(message.title, message.message, message.priority);
          }
        });
        
        Shiny.addCustomMessageHandler('hideAnnouncementBanner', function(message) {
          if (typeof window.hideAnnouncementBanner === 'function') {
            window.hideAnnouncementBanner();
          }
        });
        
        Shiny.addCustomMessageHandler('toggleAnnouncementPanel', function(message) {
          if (typeof window.toggleAnnouncementPanel === 'function') {
            window.toggleAnnouncementPanel();
          }
        });
        
        Shiny.addCustomMessageHandler('markAllAsRead', function(message) {
          if (typeof window.markAllAsRead === 'function') {
            window.markAllAsRead();
          }
        });
        
        Shiny.addCustomMessageHandler('clearAllNotifications', function(message) {
          if (typeof window.clearAllNotifications === 'function') {
            window.clearAllNotifications();
          }
        });
        
        Shiny.addCustomMessageHandler('toggleNotificationCenter', function(message) {
          if (typeof window.toggleNotificationCenter === 'function') {
            window.toggleNotificationCenter();
          }
        });
        
        // Gestionnaire pour les notifications flottantes
        Shiny.addCustomMessageHandler('showVoteNotification', function(message) {
          if (typeof window.showVoteNotification === 'function') {
            window.showVoteNotification(message.id, message.title, message.message, message.type, message.duration);
          } else {
            console.error('showVoteNotification function not found');
          }
        });
        
        // Gestionnaire pour les notifications de bienvenue (sans historique)
        Shiny.addCustomMessageHandler('showWelcomeNotification', function(message) {
          if (typeof window.showWelcomeNotification === 'function') {
            window.showWelcomeNotification(message.id, message.title, message.message, message.type, message.duration);
          } else {
            console.error('showWelcomeNotification function not found');
          }
        });
        
        // Fonctions pour naviguer vers les pages cachées (portée globale)
        window.showIdeasPage = function() {
          $('.hidden-page').hide();
          $('#ideas-page').addClass('show').show();
          $('.tab-content').hide();
          if (!$('#ideas-page .back-btn').length) {
            $('#ideas-page').prepend('<button class=\"back-btn\" onclick=\"hideHiddenPages()\"><i class=\"fa fa-arrow-left\"></i> Retour</button>');
          }
        };
        
        window.showParticipationPage = function() {
          $('.hidden-page').hide();
          $('#participation-page').addClass('show').show();
          $('.tab-content').hide();
          if (!$('#participation-page .back-btn').length) {
            $('#participation-page').prepend('<button class=\"back-btn\" onclick=\"hideHiddenPages()\"><i class=\"fa fa-arrow-left\"></i> Retour</button>');
          }
        };
        
        window.hideHiddenPages = function() {
          $('.hidden-page').removeClass('show').hide();
          $('.tab-content').show();
          // Réactiver l'onglet actuel
          $('.nav-link.active').click();
        };
        
        // Fonctions de gestion des thèmes (déplacées depuis ui_home.R)
        function setTheme(theme) {
          localStorage.setItem('app-theme', theme);
          applyTheme(theme);
          
          // Mettre à jour l'indicateur visuel
          $('.theme-option').removeClass('active');
          $('[onclick*=\"setTheme(\\'' + theme + '\\')\"').addClass('active');
        }
        
        function applyTheme(theme) {
          const html = document.documentElement;
          const body = document.body;
          
          // Supprimer toutes les classes de thème existantes
          html.classList.remove('theme-light', 'theme-dark', 'theme-auto');
          body.classList.remove('theme-light', 'theme-dark', 'theme-auto');
          
          if (theme === 'dark') {
            html.classList.add('theme-dark');
            body.classList.add('theme-dark');
            applyDarkTheme();
          } else if (theme === 'light') {
            html.classList.add('theme-light');
            body.classList.add('theme-light');
            applyLightTheme();
          } else if (theme === 'auto') {
            html.classList.add('theme-auto');
            body.classList.add('theme-auto');
            // Détecter la préférence système
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
              applyDarkTheme();
            } else {
              applyLightTheme();
            }
          }
        }
        
        function applyDarkTheme() {
          const style = document.createElement('style');
          style.id = 'dark-theme-styles';
          // Supprimer les styles existants
          const existing = document.getElementById('dark-theme-styles');
          if (existing) existing.remove();
          
          style.innerHTML = `
            body.theme-dark, html.theme-dark {
              background-color: #1a1a1a !important;
              color: #e0e0e0 !important;
            }
            
            .theme-dark .card {
              background-color: #2d2d2d !important;
              border-color: #404040 !important;
              color: #e0e0e0 !important;
            }
            
            .theme-dark .card-body {
              background: linear-gradient(135deg, #2d2d2d, #1f1f1f) !important;
              color: #e0e0e0 !important;
            }
            
            .theme-dark .card-header {
              background-color: #2d2d2d !important;
              color: #e0e0e0 !important;
              border-bottom-color: #404040 !important;
            }
            
            .theme-dark .card-title {
              color: #ffffff !important;
            }
            
            .theme-dark .home-banner {
              filter: brightness(0.8);
            }
            
            .theme-dark .document-item, .theme-dark .event-item {
              background: rgba(255,255,255,0.05) !important;
              color: #e0e0e0 !important;
            }
            
            .theme-dark .document-item:hover, .theme-dark .event-item:hover {
              background: rgba(255,255,255,0.1) !important;
            }
            
            .theme-dark .text-muted {
              color: #b0b0b0 !important;
            }
            
            .theme-dark .dropdown-menu {
              background-color: #2d2d2d !important;
              border-color: #404040 !important;
            }
            
            .theme-dark .dropdown-item {
              color: #e0e0e0 !important;
            }
            
            .theme-dark .dropdown-item:hover {
              background-color: rgba(63, 81, 181, 0.2) !important;
              color: #ffffff !important;
            }
          `;
          
          document.head.appendChild(style);
        }
        
        function applyLightTheme() {
          // Supprimer les styles du thème sombre
          const darkStyles = document.getElementById('dark-theme-styles');
          if (darkStyles) darkStyles.remove();
        }
        
        function loadSavedTheme() {
          const savedTheme = localStorage.getItem('app-theme') || 'light';
          applyTheme(savedTheme);
          
          // Mettre à jour l'indicateur visuel
          $('.theme-option').removeClass('active');
          $('[onclick*=\"setTheme(\\'' + savedTheme + '\\')\"').addClass('active');
        }
        
        // Écouter les changements de préférence système pour le mode auto
        if (window.matchMedia) {
          window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
            const currentTheme = localStorage.getItem('app-theme');
            if (currentTheme === 'auto') {
              applyTheme('auto');
            }
          });
        }
        
        // Exposer les fonctions globalement
        window.setTheme = setTheme;
        window.applyTheme = applyTheme;
        window.loadSavedTheme = loadSavedTheme;
        
        // Fonction pour initialiser le bouton Haut de page
        function initScrollToTopButton() {
          var scrollToTopBtn = $('#scroll-to-top');
          
          // Afficher/masquer le bouton selon le scroll
          $(window).scroll(function() {
            if ($(window).scrollTop() > 300) {
              scrollToTopBtn.addClass('show');
            } else {
              scrollToTopBtn.removeClass('show');
            }
          });
          
          // Action de clic pour remonter en haut
          scrollToTopBtn.click(function() {
            $('html, body').animate({
              scrollTop: 0
            }, 800, 'swing');
            return false;
          });
          
          // Effet de survol amélioré
          scrollToTopBtn.hover(
            function() {
              $(this).css('transform', 'translateY(-3px) scale(1.05)');
            },
            function() {
              $(this).css('transform', 'translateY(0) scale(1)');
            }
          );
        }
      "))
    ),
    bslib::nav_panel("Accueil", icon = icon("home"), source("ui/ui_home.R")$value),
    bslib::nav_panel("Scrutin des classes", icon = icon("user-graduate"), source("ui/ui_delegates.R")$value),
    bslib::nav_panel("Candidats au scrutin AES", icon = icon("user-tie"), source("ui/ui_candidates.R")$value),
    bslib::nav_panel("Votes AES", icon = icon("check-to-slot"), source("ui/ui_vote.R")$value),
    bslib::nav_panel("Statistiques", icon = icon("chart-pie"), source("ui/ui_stats.R")$value),
    bslib::nav_panel("Résultats", icon = icon("chart-column"), source("ui/ui_results.R")$value),
    bslib::nav_panel("Administration", icon = icon("shield-halved"), div(id = "admin-container", class = "admin-module-container", admin_ui("admin"))),
    bslib::nav_spacer(),
    bslib::nav_item(
      div(class = "dropdown theme-dropdown",
        tags$button(
          class = "btn theme-btn dropdown-toggle",
          type = "button",
          id = "themeDropdown",
          `data-bs-toggle` = "dropdown",
          `aria-expanded` = "false",
          title = "Changer le thème",
          icon("palette", class = "fa-lg")
        ),
        div(class = "dropdown-menu dropdown-menu-end theme-menu",
          `aria-labelledby` = "themeDropdown",
          h6(class = "dropdown-header d-flex align-items-center",
            icon("palette", class = "me-2"),
            "Thème d'affichage"
          ),
          div(class = "dropdown-divider"),
          tags$a(
            class = "dropdown-item theme-option",
            href = "#",
            onclick = "setTheme('light')",
            icon("sun", class = "me-2"),
            "Mode clair"
          ),
          tags$a(
            class = "dropdown-item theme-option",
            href = "#",
            onclick = "setTheme('dark')",
            icon("moon", class = "me-2"),
            "Mode sombre"
          ),
          tags$a(
            class = "dropdown-item theme-option",
            href = "#",
            onclick = "setTheme('auto')",
            icon("adjust", class = "me-2"),
            "Mode automatique"
          )
        )
      )
    )
  ),
  
  # Boutons flottants pour "Boîte à Idées" et "Participation"
  div(class = "floating-nav-buttons",
    actionButton("btn_ideas", "", 
                icon = icon("lightbulb"), 
                class = "floating-btn floating-btn-ideas",
                title = "Boîte à Idées",
                onclick = "showIdeasPage()"),
    actionButton("btn_participation", "", 
                icon = icon("trophy"), 
                class = "floating-btn floating-btn-participation",
                title = "Participation",
                onclick = "showParticipationPage()")
  ),
  
  # Pages cachées pour "Boîte à Idées" et "Participation"
  div(id = "ideas-page", class = "hidden-page", style = "display: none;",
    source("ui/ui_ideas.R")$value
  ),
  
  div(id = "participation-page", class = "hidden-page", style = "display: none;",
    div(id = "participation-container", class = "participation-container",
      source("ui/ui_gamification.R", local = TRUE)$value
    )
  ),
  
  # Bouton "Haut de page"
  div(id = "scroll-to-top", class = "scroll-to-top-btn",
    icon("arrow-up", class = "fa-lg"),
    span("Haut de page", class = "btn-text")
  ),
  
  # Champ caché pour le statut d'administrateur
  tags$input(type = "hidden", name = "user_is_admin", value = "false")
) 
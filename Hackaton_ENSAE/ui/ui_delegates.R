div(class = "container delegates-container",
  div(class = "spacer", style = "height: 10px;"),
  
  # CSS amélioré pour la page délégués de classe
  tags$style(HTML("
    /* Styles améliorés pour les onglets et conteneurs */
    .delegates-container {
      animation: fadeIn 0.8s ease-in-out;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Style pour les onglets de délégués */
    .delegate-tab-active {
      background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
      color: white !important;
      border: none !important;
      border-radius: 8px 8px 0 0 !important;
      position: relative;
      z-index: 5;
      padding: 15px 20px !important;
      box-shadow: 0 -4px 10px rgba(0,0,0,0.1);
      font-weight: bold !important;
      transform: translateY(-5px);
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) !important;
    }
    
    /* Rendre les onglets plus visibles */
    #delegate_type .nav-tabs .nav-link {
      font-weight: bold;
      font-size: 1.1rem;
      color: #3f51b5;
      border: 1px solid #dee2e6;
      background-color: #f8f9fa;
    }
    
    #delegate_type .nav-tabs .nav-link.active {
      background-color: #3f51b5 !important;
      color: white !important;
      border-color: #3f51b5 !important;
    }
    
    .nav-tabs .nav-link {
      transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      border: 1px solid #dee2e6;
      background-color: #f8f9fa;
      margin-right: 5px;
      border-radius: 8px 8px 0 0;
      font-weight: 500;
      padding: 12px 20px !important;
    }
    
    .nav-tabs .nav-link:hover:not(.active) {
      background-color: #e9ecef;
      border-color: #ced4da;
      transform: translateY(-3px);
      box-shadow: 0 -2px 8px rgba(0,0,0,0.08);
    }
    
    /* Indicateur de sélection */
    .delegate-tab-active::after {
      content: '';
      position: absolute;
      bottom: -2px;
      left: 0;
      width: 100%;
      height: 3px;
      background: linear-gradient(90deg, #007bff, #00c6ff);
    }
    
    /* Container des onglets */
    #delegate_type > .tab-content {
      border: none;
      padding: 25px;
      background-color: white;
      border-radius: 0 8px 8px 8px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.08);
    }
    
    /* Style pour les onglets non actifs */
    #delegate_type > ul > li > a:not(.delegate-tab-active) {
      color: #495057;
    }
    
    /* Styles pour les cartes */
    .delegate-card {
      border: none !important;
      border-radius: 12px !important;
      overflow: hidden;
      transition: all 0.4s ease;
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.12) !important;
    }
    

    
    .class-selector h4 {
      display: inline-block;
      position: relative;
      font-weight: 600;
      color: #2c3e50;
      margin-bottom: 5px;
    }
    
    .delegate-card:hover {
      transform: translateY(-8px);
      box-shadow: 0 12px 30px rgba(63, 81, 181, 0.2) !important;
    }
    
    .delegate-card-header {
      background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
      color: white !important;
      border-bottom: none !important;
      padding: 20px !important;
    }
    
    .delegate-card-header h3 {
      font-weight: 600;
      letter-spacing: 0.5px;
      text-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .delegate-card-header .icon {
      font-size: 2rem;
      background: rgba(255,255,255,0.15);
      border-radius: 50%;
      width: 60px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    
    /* Styles pour les boutons de classe */
    .class-btn {
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      font-weight: 500;
      border-radius: 8px;
      padding: 10px 15px;
      margin: 5px;
      border: none;
      background-color: #f0f4f8;
      color: #495057;
      box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    
    .class-btn:hover {
      transform: translateY(-4px) scale(1.05);
      box-shadow: 0 5px 12px rgba(0,0,0,0.1);
      z-index: 5;
    }
    
    .class-btn.active {
      font-weight: 600;
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white;
      box-shadow: 0 5px 12px rgba(63, 81, 181, 0.3);
      transform: translateY(-4px) scale(1.05);
      border: 2px solid #3f51b5;
      position: relative;
      z-index: 10;
    }
    
    /* Animation lors de la sélection */
    .class-btn.active::after {
      content: '';
      position: absolute;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      border-radius: 6px;
      animation: pulse 1.5s infinite;
      z-index: -1;
    }
    
    @keyframes pulse {
      0% { box-shadow: 0 0 0 0 rgba(63, 81, 181, 0.7); }
      70% { box-shadow: 0 0 0 10px rgba(63, 81, 181, 0); }
      100% { box-shadow: 0 0 0 0 rgba(63, 81, 181, 0); }
    }
    
    .results-class-btn {
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      font-weight: 500;
      border-radius: 8px;
      padding: 10px 15px;
      margin: 5px;
      border: none;
      background-color: #f0f8f4;
      color: #495057;
      box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    
    .results-class-btn:hover {
      transform: translateY(-4px) scale(1.05);
      box-shadow: 0 5px 12px rgba(0,0,0,0.1);
      z-index: 5;
    }
    
    .results-class-btn.active {
      font-weight: 600;
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white;
      box-shadow: 0 5px 12px rgba(63, 81, 181, 0.3);
      transform: translateY(-4px) scale(1.05);
      border: 2px solid #3f51b5;
      position: relative;
      z-index: 10;
    }
    
    /* Animation lors de la sélection */
    .results-class-btn.active::after {
      content: '';
      position: absolute;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      border-radius: 6px;
      animation: pulse 1.5s infinite;
      z-index: -1;
    }
    
    /* Style pour les boutons de vote */
    .btn-vote {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      border: none;
      border-radius: 50px;
      padding: 12px 30px;
      font-weight: 600;
      letter-spacing: 0.5px;
      box-shadow: 0 5px 15px rgba(63, 81, 181, 0.3);
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    
    .btn-vote:hover {
      transform: translateY(-5px) scale(1.05);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.4);
    }
    
    /* Styles pour les résultats */
    .results-card {
      border: none !important;
      border-radius: 12px !important;
      overflow: hidden;
      transition: all 0.4s ease;
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.12) !important;
    }
    
    .results-card:hover {
      transform: translateY(-8px);
      box-shadow: 0 12px 30px rgba(63, 81, 181, 0.2) !important;
    }
    
    .results-card-header {
      background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
      color: white !important;
      border-bottom: none !important;
      padding: 20px !important;
    }
    
    .results-title {
      font-weight: 600;
      letter-spacing: 0.5px;
      position: relative;
      padding-bottom: 10px;
      margin-bottom: 20px;
      text-align: center;
    }
    
    .results-title::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background: linear-gradient(90deg, #3f51b5, #5c6bc0);
      border-radius: 3px;
    }
    
    /* Styles pour les radio buttons */
    .delegate-radio .form-check {
      padding: 12px 15px;
      margin-bottom: 10px;
      border-radius: 8px;
      transition: all 0.3s ease;
      border: 2px solid transparent;
      background-color: #f8f9fa;
    }
    
    .delegate-radio .form-check:hover {
      background-color: #e9f5ff;
      transform: translateX(5px);
    }
    
    .delegate-radio .form-check-input:checked + .form-check-label {
      font-weight: 600;
      color: #3f51b5;
    }
    
    .delegate-radio .form-check-input:checked ~ .form-check {
      border-color: #3f51b5;
      background-color: #e9f5ff;
    }
    
    /* Style des boutons radio amélioré */
    .delegate-radio .form-check-input {
      width: 20px;
      height: 20px;
    }
    
    .delegate-radio .form-check-input:checked {
      background-color: #3f51b5 !important;
      border-color: #3f51b5 !important;
      box-shadow: 0 0 0 0.2rem rgba(63, 81, 181, 0.25) !important;
    }
    
    /* Animation pour les sélections de classe */
    .class-selector, .results-class-selector {
      position: relative;
    }
    
    .class-selector h4, .results-class-selector h4 {
      display: inline-block;
      position: relative;
      font-weight: 600;
      color: #2c3e50;
      margin-bottom: 5px;
    }
    
    .class-selector h4::after, .results-class-selector h4::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 0;
      width: 60px;
      height: 3px;
      background: linear-gradient(90deg, #007bff, #00c6ff);
      border-radius: 3px;
      transition: width 0.3s ease;
    }
    
    .class-selector h4:hover::after, .results-class-selector h4:hover::after {
      width: 100%;
    }
    
    /* Style pour la grille de boutons */
    .class-buttons-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-bottom: 25px;
      background-color: #f8f9fa;
      border-radius: 12px;
      padding: 15px;
      box-shadow: inset 0 2px 5px rgba(0,0,0,0.05);
    }
    
    /* Style mobile pour les onglets */
    @media (max-width: 768px) {
      .delegate-tab-active {
        border-radius: 8px !important;
        margin-bottom: 8px;
      }
      
      .nav-tabs {
        border-bottom: none;
        display: flex;
        flex-direction: column;
        gap: 8px;
      }
      
      .nav-tabs .nav-link {
        margin-bottom: 0;
        border-radius: 8px;
        text-align: center;
      }
      
      #delegate_type > .tab-content {
        border-radius: 8px;
        border: none;
      }
      
      .class-buttons-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
      }
      
      .btn-vote {
        width: 100%;
      }
    }
  ")),
  
  # JavaScript amélioré pour maintenir la sélection des boutons de classe
  tags$script(HTML("
    $(document).ready(function() {
      // Animation d'entrée pour les cartes
      $('.delegate-card, .results-card').hide().fadeIn(800);
      
      // Gestion des boutons de classe pour le vote
      $('.class-btn').on('click', function() {
        // Supprimer la classe active de tous les boutons
        $('.class-btn').removeClass('active');
        // Réinitialiser les styles de tous les boutons
        $('.class-btn').css({
          'background': '#f0f4f8',
          'color': '#495057',
          'transform': 'none',
          'box-shadow': '0 2px 5px rgba(0,0,0,0.05)',
          'border': 'none'
        });
        
        // Ajouter la classe active au bouton cliqué avec animation
        $(this).addClass('active').css({
          'background': 'linear-gradient(135deg, #3f51b5, #303f9f)',
          'color': 'white',
          'transform': 'scale(1.1)',
          'box-shadow': '0 5px 12px rgba(63, 81, 181, 0.3)',
          'border': '2px solid #3f51b5'
        });
        
        setTimeout(function() {
          $('.class-btn.active').css('transform', 'translateY(-4px) scale(1.05)');
        }, 200);
      });
      
      // Gestion des boutons de classe pour les résultats
      $('.results-class-btn').on('click', function() {
        // Supprimer la classe active de tous les boutons
        $('.results-class-btn').removeClass('active');
        // Réinitialiser les styles de tous les boutons
        $('.results-class-btn').css({
          'background': '#f0f8f4',
          'color': '#495057',
          'transform': 'none',
          'box-shadow': '0 2px 5px rgba(0,0,0,0.05)',
          'border': 'none'
        });
        
        // Ajouter la classe active au bouton cliqué avec animation
        $(this).addClass('active').css({
          'background': 'linear-gradient(135deg, #3f51b5, #303f9f)',
          'color': 'white',
          'transform': 'scale(1.1)',
          'box-shadow': '0 5px 12px rgba(63, 81, 181, 0.3)',
          'border': '2px solid #3f51b5'
        });
        
        setTimeout(function() {
          $('.results-class-btn.active').css('transform', 'translateY(-4px) scale(1.05)');
        }, 200);
      });
      
      // Gestion des onglets de délégués
      $('#delegate_type > ul > li > a').on('click', function() {
        // Supprimer la classe active de tous les onglets
        $('#delegate_type > ul > li > a').removeClass('delegate-tab-active');
        // Ajouter la classe active à l'onglet cliqué
        $(this).addClass('delegate-tab-active');
        
        // Ajouter une classe active visible
        $('#delegate_type > ul > li > a').removeClass('active');
        $(this).addClass('active');
        
        // Effet visuel additionnel
        $(this).css('background-color', '#3f51b5').css('color', 'white');
      });
      
      // Initialiser le premier onglet comme actif
      $('#delegate_type > ul > li:first-child > a').addClass('delegate-tab-active').addClass('active').css('background-color', '#3f51b5').css('color', 'white');
      
      // S'assurer que les titres des onglets restent en bleu et gras
      $('.delegate-tab-title').css({
        'color': '#3f51b5',
        'font-weight': 'bold',
        'font-size': '1.2rem'
      });
      
      // Maintenir le style bleu et gras lors du changement d'onglet
      $(document).on('shown.bs.tab', '#delegate_type a[data-toggle="tab"]', function() {
        $('.delegate-tab-title').css({
          'color': '#3f51b5',
          'font-weight': 'bold',
          'font-size': '1.2rem'
        });
      });
      
      // Animation pour les résultats
      $('.results-title').each(function() {
        $(this).css('opacity', '0').css('transform', 'translateY(20px)');
        setTimeout(function(el) {
          $(el).css('transition', 'all 0.8s ease').css('opacity', '1').css('transform', 'translateY(0)');
        }, 300, this);
      });
      
      // Effet de survol pour les boutons
      $('.btn-vote').hover(
        function() {
          $(this).css('background', 'linear-gradient(135deg, #0056b3, #007bff)');
        },
        function() {
          $(this).css('background', 'linear-gradient(135deg, #007bff, #0056b3)');
        }
      );
    });
  ")),
  
  # Carte améliorée pour le vote des délégués
  div(class = "delegate-card shadow-sm border-primary", style = "margin-bottom: 30px;",
    div(class = "delegate-card-header bg-light d-flex align-items-center",
      div(class = "icon me-3", 
        icon("users", class = "text-white")
      ),
        h3("Élection des Délégués de Classe", class = "mb-0")
    ),
    div(class = "card-body p-4",
      div(class = "intro-text mb-2",
        p(class = "lead mb-1", "Votez pour le délégué et le délégué-adjoint de votre classe."),
        p(class = "text-muted small mb-0", "Les délégués élus représenteront votre classe lors des conseils et réunions officielles de l'établissement.")
      ),
      hr(),
      hr(),
      # Sélecteur de classe avec boutons
      
        h4("Choisissez une classe"),
        div(class = "class-buttons-grid",
          # AS
          div(class = "btn-group", role = "group",
            actionButton("class_as1", "AS1", class = "class-btn"),
            actionButton("class_as2", "AS2", class = "class-btn"),
            actionButton("class_as3", "AS3", class = "class-btn")
          ),
          # ISEP
          div(class = "btn-group", role = "group",
            actionButton("class_isep1", "ISEP1", class = "class-btn"),
            actionButton("class_isep2", "ISEP2", class = "class-btn"),
            actionButton("class_isep3", "ISEP3", class = "class-btn")
          ),
          # ISE
          div(class = "btn-group", role = "group", 
            actionButton("class_ise1", "ISE1", class = "class-btn"),
            actionButton("class_ise2", "ISE2", class = "class-btn"),
            actionButton("class_ise3", "ISE3", class = "class-btn"),
            actionButton("class_masters", "Masters", class = "class-btn")
          )
        ),
        # Afficher la classe sélectionnée
        div(class = "selected-class-display", 
        uiOutput("selected_class_display")
        )
      ,
      
      # Style personnalisé pour les titres des onglets
      tags$style(HTML("
        .delegate-tab-title {
          color: #3f51b5 !important;
          font-weight: bold !important;
          font-size: 1.2rem !important;
        }
      ")),
      
      # Onglets pour délégué principal et adjoint
      tabsetPanel(id = "delegate_type",
        tabPanel(span("Délégué Principal", class = "delegate-tab-title"), 
          value = "main",
          div(class = "mt-4 delegate-radio",
            uiOutput("main_delegate_choices")
          )
        ),
        tabPanel(span("Délégué Adjoint", class = "delegate-tab-title"), 
          value = "deputy",
          div(class = "mt-4 delegate-radio",
            uiOutput("deputy_delegate_choices")
          )
        )
      ),
      
      # Bouton de vote
      div(class = "d-flex justify-content-center mt-4 mb-3",
        actionButton("submit_delegate_vote", "Voter", class = "btn btn-lg btn-vote", 
                    icon = icon("check-to-slot"))
      )
    )
  ),
  
  # Résultats actuels
  div(class = "results-card shadow-sm border-success mt-4",
    div(class = "results-card-header bg-light d-flex align-items-center", 
      div(class = "icon me-3", 
        icon("chart-column", class = "text-white")
      ),
      h3("Résultats Actuels", class = "mb-0")
    ),
    div(class = "card-body p-4",
      # Sélecteur de classe pour les résultats avec boutons
      div(class = "results-class-selector mb-4 floating-element",
        h4("Afficher les résultats pour la classe", class = "mb-4"),
        div(class = "class-buttons-grid",
          # AS
          div(class = "btn-group", role = "group",
            actionButton("results_as1", "AS1", class = "results-class-btn"),
            actionButton("results_as2", "AS2", class = "results-class-btn"),
            actionButton("results_as3", "AS3", class = "results-class-btn")
          ),
          # ISEP
          div(class = "btn-group", role = "group",
            actionButton("results_isep1", "ISEP1", class = "results-class-btn"),
            actionButton("results_isep2", "ISEP2", class = "results-class-btn"),
            actionButton("results_isep3", "ISEP3", class = "results-class-btn")
          ),
          # ISE
          div(class = "btn-group", role = "group", 
            actionButton("results_ise1", "ISE1", class = "results-class-btn"),
            actionButton("results_ise2", "ISE2", class = "results-class-btn"),
            actionButton("results_ise3", "ISE3", class = "results-class-btn"),
            actionButton("results_masters", "Masters", class = "results-class-btn")
          )
        ),
        # Afficher la classe sélectionnée pour les résultats
        div(class = "selected-results-class", 
        uiOutput("selected_results_class_display")
        )
      ),
      
      # Affichage des résultats
      div(class = "row mt-4 g-4",
        div(class = "col-md-6",
          div(class = "chart-container bg-white p-3 rounded shadow-sm h-100",
            h5(class = "results-title", "Délégué Principal"),
          plotOutput("main_delegate_results", height = "300px")
          )
        ),
        div(class = "col-md-6",
          div(class = "chart-container bg-white p-3 rounded shadow-sm h-100",
            h5(class = "results-title", "Délégué Adjoint"),
          plotOutput("deputy_delegate_results", height = "300px")
          )
        )
      ),
      
      # Tableau récapitulatif
      div(class = "details-container bg-white p-3 rounded shadow-sm mt-4", 
        h5(class = "results-title", "Détails des votes"),
        div(class = "table-responsive",
      tableOutput("delegate_votes_table")
        )
      ),
      
      # Statistiques de participation
      div(class = "participation-stats mt-4 p-3 bg-light rounded",
        div(class = "row align-items-center",
          div(class = "col-md-4 text-center border-end",
            icon("users", class = "mb-2 text-primary"),
            h5("Électeurs inscrits"),
            div(class = "stats-value", textOutput("registered_voters"))
          ),
          div(class = "col-md-4 text-center border-end",
            icon("check-to-slot", class = "mb-2 text-success"),
            h5("Votes exprimés"),
            div(class = "stats-value", textOutput("votes_count"))
          ),
          div(class = "col-md-4 text-center",
            icon("percent", class = "mb-2 text-info"),
            h5("Taux de participation"),
            div(class = "stats-value", textOutput("participation_percentage"))
          )
        )
      )
    )
  ),
  
  # Bouton d'action flottant pour voter rapidement
  div(class = "floating-action", id = "quick_delegate_vote_button", title = "Voter maintenant",
    icon("check-to-slot")
  )
) 
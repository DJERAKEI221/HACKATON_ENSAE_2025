# Page UI pour la gamification
# Cette page montre les badges, le leaderboard et les statistiques de participation

div(class = "container gamification-container",
  # Inclure la feuille de style externe
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/gamification.css"),
    tags$script(src = "js/gamification.js"),
    # Ajouter des styles en ligne au cas où
    tags$style(HTML("
      /* Styles des badges en ligne */
      .badges-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        justify-content: center;
        padding: 10px 0;
        width: 100%;
      }
      
      .badge-card {
        flex: 0 0 auto;
        width: 110px;
        background: #f8f9fa;
        border-radius: 12px;
        padding: 10px;
        text-align: center;
        transition: all 0.3s ease;
        box-shadow: 0 3px 10px rgba(0,0,0,0.05);
        margin-bottom: 10px;
      }
      
      .badge-icon {
        width: 60px;
        height: 60px;
        margin: 0 auto 8px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 30px;
        background: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      }
      
      .badge-icon.earned {
        background: linear-gradient(135deg, #3f51b5, #5c6bc0);
        color: white;
        box-shadow: 0 6px 12px rgba(63, 81, 181, 0.3);
        border: 2px solid white;
      }
      
      .badge-name {
        font-weight: 600;
        font-size: 0.9rem;
        margin: 8px 0 3px;
      }
      
      .badge-description {
        font-size: 0.75rem;
        color: #6c757d;
        line-height: 1.3;
      }
      
      /* Style pour la mise en page en colonnes */
      .main-row {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        margin-bottom: 30px;
      }
      
      .badges-column, .stats-column {
        flex: 1;
        min-width: 300px;
        background: white;
        border-radius: 15px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        padding: 20px;
        margin-bottom: 20px;
      }
      
      /* Style pour le tableau de classement */
      .leaderboard-container {
        width: 100%;
        background: white;
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.05);
        margin-top: 20px;
        border: 1px solid rgba(226, 232, 240, 0.5);
      }

      .leaderboard-title {
        font-weight: 700;
        color: #1a202c;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 2px solid #edf2f7;
        font-size: 1.4rem;
        display: flex;
        align-items: center;
      }

      .leaderboard-title .section-icon {
        margin-right: 15px;
      }

      .leaderboard-row {
        display: flex;
        align-items: center;
        padding: 15px 10px;
        border-bottom: 1px solid #edf2f7;
        transition: all 0.2s ease;
        border-radius: 8px;
        flex-wrap: wrap;
      }

      .leaderboard-row:hover {
        background-color: #f7fafc;
        transform: translateX(5px);
      }

      .leaderboard-position {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        background: #edf2f7;
        color: #4a5568;
        font-weight: 700;
        margin-right: 15px;
        font-size: 1.2rem;
      }

      .leaderboard-voter-info {
        flex: 1;
        min-width: 200px;
        margin-right: 15px;
      }

      .leaderboard-name {
        font-weight: 600;
        color: #2d3748;
        font-size: 1.05rem;
      }

      .leaderboard-class {
        font-size: 0.85em;
        color: #6c757d;
        font-style: italic;
      }
      
      .leaderboard-votes-detail {
        display: flex;
        flex-direction: column;
        margin-right: 15px;
        min-width: 100px;
      }
      
      .vote-count {
        font-size: 0.9rem;
        display: flex;
        justify-content: space-between;
        padding: 2px 0;
      }
      
      .aes-votes .vote-value {
        color: #3f51b5;
        font-weight: 600;
      }
      
      .delegate-votes .vote-value {
        color: #4caf50;
        font-weight: 600;
      }
      
      .leaderboard-score {
        text-align: right;
        min-width: 120px;
      }
      
      .total-votes {
        font-size: 0.9rem;
        margin-bottom: 4px;
      }
      
      .vote-total-value {
        font-weight: 700;
        color: #ff9800;
      }
      
      .score-points {
        background: rgba(63, 81, 181, 0.1);
        padding: 4px 10px;
        border-radius: 20px;
        display: inline-block;
      }
      
      .score-value {
        font-weight: bold;
        color: #3f51b5;
      }
      
      .score-label {
        font-size: 0.9em;
      }
      
      /* Styles spéciaux pour les trois premiers */
      .leaderboard-position.top-1 {
        background: linear-gradient(135deg, #FFD700, #FFA500);
        color: white;
        box-shadow: 0 5px 15px rgba(255, 165, 0, 0.3);
      }

      .leaderboard-position.top-2 {
        background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
        color: white;
        box-shadow: 0 5px 15px rgba(169, 169, 169, 0.3);
      }

      .leaderboard-position.top-3 {
        background: linear-gradient(135deg, #CD7F32, #8B4513);
        color: white;
        box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
      }
      
      /* Responsive */
      @media (max-width: 768px) {
        .leaderboard-row {
          flex-direction: column;
          align-items: flex-start;
          padding: 15px;
        }
        
        .leaderboard-position {
          margin-bottom: 10px;
        }
        
        .leaderboard-voter-info,
        .leaderboard-votes-detail,
        .leaderboard-score {
          width: 100%;
          margin-bottom: 10px;
          text-align: left;
        }
      }
    "))
  ),
  
  div(class = "spacer", style = "height: 10px;"),
  
  # Zone de test pour vérifier que les rendus fonctionnent
  div(class = "alert alert-info",
    h4("Statut du Système"),
    textOutput("test_output"),
    textOutput("participation-test_output")
  ),
  
  # Conteneur flex pour mettre les colonnes côte à côte
  div(class = "main-row",
    # Colonne des badges et réalisations
    div(class = "badges-column",
      div(class = "section-header",
        div(class = "section-icon", icon("trophy")),
        h3(class = "section-title", "Badges et Réalisations")
      ),
      
      # Grille de badges
      div(class = "badges-grid",
        # Conteneur des badges dynamiques - sera rempli par le serveur
        uiOutput("participation-badges_container")
      )
    ),
    
    # Colonne des statistiques
    div(class = "stats-column",
      div(class = "section-header",
        div(class = "section-icon", icon("chart-line")),
        h3(class = "section-title", "Vos Statistiques")
      ),
      
      # Liste des statistiques
      div(class = "stats-list",
        # Conteneur des statistiques - sera rempli dynamiquement
        uiOutput("participation-stats_container")
      )
    )
  ),
  
  # Tableau de classement
  div(class = "leaderboard-container",
    div(class = "leaderboard-title",
      div(class = "section-icon", icon("vote-yea")),
      span("Classement des Votants par Nombre de Votes")
    ),
    
    # Liste des participants - sera remplie dynamiquement
    div(class = "leaderboard-list",
      # Conteneur du leaderboard dynamique - sera rempli avec les votants réels
      uiOutput("participation-leaderboard_container")
    ),
    
    # Ajouter un script JavaScript pour permettre le rafraîchissement manuel du classement
    tags$script(HTML("
      Shiny.addCustomMessageHandler('refresh-leaderboard', function(message) {
        console.log('Rafraîchissement du classement demandé');
        // Forcer le rafraîchissement du conteneur du classement
        Shiny.setInputValue('refresh_leaderboard_trigger', Math.random());
      });
    ")),
    
    tags$style(HTML("
      /* Styles pour le tableau de classement */
      .leaderboard-row {
        display: flex;
        align-items: center;
        padding: 15px 10px;
        border-bottom: 1px solid #edf2f7;
        transition: all 0.2s ease;
        border-radius: 8px;
        flex-wrap: wrap;
      }
      
      .leaderboard-position {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        background: #edf2f7;
        color: #4a5568;
        font-weight: 700;
        margin-right: 15px;
        font-size: 1.2rem;
      }
      
      .leaderboard-voter-info {
        flex: 1;
        min-width: 200px;
        margin-right: 15px;
      }
      
      .leaderboard-name {
        font-weight: 600;
        color: #2d3748;
        font-size: 1.05rem;
      }
      
      .leaderboard-class {
        font-size: 0.85em;
        color: #6c757d;
        font-style: italic;
      }
      
      .leaderboard-votes-detail {
        display: flex;
        flex-direction: column;
        margin-right: 15px;
        min-width: 100px;
      }
      
      .vote-count {
        font-size: 0.9rem;
        display: flex;
        justify-content: space-between;
        padding: 2px 0;
      }
      
      .aes-votes .vote-value {
        color: #3f51b5;
        font-weight: 600;
      }
      
      .delegate-votes .vote-value {
        color: #4caf50;
        font-weight: 600;
      }
      
      .leaderboard-score {
        text-align: right;
        min-width: 120px;
      }
      
      .total-votes {
        font-size: 0.9rem;
        margin-bottom: 4px;
      }
      
      .vote-total-value {
        font-weight: 700;
        color: #ff9800;
      }
      
      .score-points {
        background: rgba(63, 81, 181, 0.1);
        padding: 4px 10px;
        border-radius: 20px;
        display: inline-block;
      }
      
      .score-value {
        font-weight: bold;
        color: #3f51b5;
      }
      
      .score-label {
        font-size: 0.9em;
      }
      
      /* Styles spéciaux pour les trois premiers */
      .leaderboard-position.top-1 {
        background: linear-gradient(135deg, #FFD700, #FFA500);
        color: white;
        box-shadow: 0 5px 15px rgba(255, 165, 0, 0.3);
      }

      .leaderboard-position.top-2 {
        background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
        color: white;
        box-shadow: 0 5px 15px rgba(169, 169, 169, 0.3);
      }

      .leaderboard-position.top-3 {
        background: linear-gradient(135deg, #CD7F32, #8B4513);
        color: white;
        box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
      }
      
      /* Responsive */
      @media (max-width: 768px) {
        .leaderboard-row {
          flex-direction: column;
          align-items: flex-start;
          padding: 15px;
        }
        
        .leaderboard-position {
          margin-bottom: 10px;
        }
        
        .leaderboard-voter-info,
        .leaderboard-votes-detail,
        .leaderboard-score {
          width: 100%;
          margin-bottom: 10px;
          text-align: left;
        }
      }
    "))
  ),
  
  # Ajouter un élément décoratif au bas de la page
  div(class = "footer-note mt-5 text-center",
    tags$p("La participation de chacun fait la force et la vitalité de notre communauté ENSAE."),
    tags$div(class = "footer-icons", "")
  )
) 
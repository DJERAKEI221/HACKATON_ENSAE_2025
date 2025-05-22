div(class = "container results-container",
  div(class = "spacer", style = "height: 10px;"), # Espace supplémentaire en haut
  
  
  # Styles CSS améliorés pour la page des résultats
  tags$style(HTML("
    /* Animation d'entrée pour la page */
    .results-container {
      animation: fadeInUp 0.8s ease-in-out;
    }
    
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Style pour la carte principale des résultats */
    .results-main-card {
      border: none !important;
      border-radius: 20px !important;
      overflow: hidden;
      transition: all 0.5s ease;
      box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1) !important;
      background: white;
    }
    
    .results-main-card:hover {
      box-shadow: 0 20px 45px rgba(0, 0, 0, 0.15) !important;
      transform: translateY(-5px);
    }
    
    .results-header {
      background: linear-gradient(135deg, #3f51b5, #303f9f) !important;
      color: white !important;
      border-bottom: none !important;
      padding: 25px 30px !important;
      position: relative;
      overflow: hidden;
    }
    
    .results-header::before {
      content: '';
      position: absolute;
      top: -50%;
      left: -50%;
      width: 200%;
      height: 200%;
      background: radial-gradient(rgba(255, 255, 255, 0.1) 8%, transparent 8%);
      background-position: 0 0;
      background-size: 30px 30px;
      opacity: 0.3;
    }
    
    .results-header .icon-container {
      background: rgba(255, 255, 255, 0.2);
      width: 60px;
      height: 60px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 20px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }
    
    .results-body {
      padding: 30px !important;
    }
    
    /* Filtres de position */
    .results-filters {
      background: linear-gradient(145deg, #f8f9fa, #ffffff);
      border-radius: 15px;
      padding: 20px;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
      margin-bottom: 25px;
      border-left: 5px solid #dee2e6;
    }
    
    .filter-header {
      margin-bottom: 15px;
    }
    
    .filter-header h4 {
      font-weight: 700;
      color: #3f51b5;
      margin-bottom: 0;
    }
    
    .position-filters {
      max-height: 300px;
      overflow-y: auto;
      padding-right: 10px;
      margin-bottom: 15px;
    }
    
    .position-filters::-webkit-scrollbar {
      width: 5px;
      display: block;
    }
    
    .position-filters::-webkit-scrollbar-thumb {
      background-color: rgba(63, 81, 181, 0.5);
      border-radius: 10px;
    }
    
    .position-filters::-webkit-scrollbar-track {
      background-color: rgba(0, 0, 0, 0.05);
      border-radius: 10px;
    }
    
    .position-filter-item {
      transition: all 0.3s ease;
    }
    
    .position-filter-item .form-check {
      padding: 10px 15px;
      border-radius: 8px;
      transition: all 0.3s ease;
    }
    
    .position-filter-item:hover .form-check {
      background-color: rgba(63, 81, 181, 0.08);
      transform: translateX(5px);
    }
    
    .form-check-input:checked {
      background-color: #3f51b5;
      border-color: #3f51b5;
    }
    
    .active-filter {
      background: linear-gradient(to right, rgba(233, 236, 239, 0.3), rgba(233, 236, 239, 0.1)) !important;
      border-radius: 8px !important;
      border-left: 3px solid #dee2e6 !important;
    }
    
    /* Style pour le bouton de réinitialisation des filtres */
    #reset_result_filters {
      background: linear-gradient(135deg, #f8f9fa, #e9ecef);
      border: 1px solid #dee2e6;
      border-radius: 30px;
      padding: 8px 15px;
      font-weight: 600;
      color: #3f51b5;
      transition: all 0.3s ease;
      box-shadow: 0 3px 8px rgba(0, 0, 0, 0.05);
    }
    
    #reset_result_filters:hover {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white;
      transform: translateY(-2px);
      box-shadow: 0 5px 15px rgba(63, 81, 181, 0.2);
    }
    
    /* Bouton de téléchargement */
    .btn-download-pv {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white !important;
      border: none;
      border-radius: 50px;
      padding: 12px 25px;
      font-weight: 600;
      box-shadow: 0 5px 15px rgba(63, 81, 181, 0.2);
      transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    
    .btn-download-pv:hover {
      transform: translateY(-5px) scale(1.05);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.3);
    }
    
    /* Graphique des résultats */
    .results-chart-container {
      background: white;
      border-radius: 15px;
      overflow: hidden;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
      margin: 30px 0;
      position: relative;
    }
    
    .results-chart-container::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 5px;
      background: linear-gradient(90deg, #3f51b5, #e8eaf6);
    }
    
    /* Détails des résultats */
    .results-details {
      animation: fadeIn 1s ease-in-out;
    }
    
    .results-details .alert-success {
      background: linear-gradient(145deg, #d1e7dd, #badbcc);
      border: none;
      border-radius: 10px;
      padding: 15px 20px;
      font-weight: 600;
      color: #0a3622;
      box-shadow: 0 4px 10px rgba(25, 135, 84, 0.1);
    }
    
    .position-section {
      background: white;
      border-radius: 15px;
      overflow: hidden;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
      margin-bottom: 30px;
      transition: all 0.3s ease;
    }
    
    .position-section:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
    }
    
    .position-header {
      background: linear-gradient(145deg, #f8f9fa, #e9ecef);
      padding: 15px 20px;
      border-bottom: 1px solid rgba(0, 0, 0, 0.05);
      font-weight: 700;
      color: #3f51b5;
      position: relative;
    }
    
    .position-header::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 20px;
      width: 50px;
      height: 3px;
      background: #dee2e6;
      border-radius: 3px;
    }
    
    .position-content {
      padding: 20px;
    }
    
    .table {
      border-collapse: separate;
      border-spacing: 0;
    }
    
    .table thead th {
      background-color: rgba(0, 0, 0, 0.03);
      border-bottom: 2px solid #dee2e6;
      font-weight: 600;
      text-transform: uppercase;
      font-size: 0.85rem;
      letter-spacing: 0.5px;
    }
    
    .table tbody tr.table-success {
      background: linear-gradient(to right, rgba(25, 135, 84, 0.15), rgba(25, 135, 84, 0.05)) !important;
    }
    
    .badge.bg-success {
      background: linear-gradient(135deg, #198754, #157347) !important;
      padding: 5px 10px;
      font-weight: 500;
      border-radius: 30px;
      box-shadow: 0 2px 5px rgba(25, 135, 84, 0.2);
    }
    
    .winner-info {
      background: linear-gradient(145deg, #f0f9ff, #e6f7ff);
      border-radius: 12px;
      padding: 20px;
      border-left: 4px solid #0dcaf0;
      box-shadow: 0 4px 10px rgba(13, 202, 240, 0.1);
    }
    
    .winner-info strong {
      color: #055160;
      font-weight: 600;
    }
    
    /* Styles adaptatifs pour mobile */
    @media (max-width: 768px) {
      .results-header {
        padding: 20px !important;
      }
      
      .results-body {
        padding: 20px !important;
      }
      
      .results-chart-container {
        margin: 20px 0;
      }
      
      .position-section {
        margin-bottom: 20px;
      }
    }
    
    /* Animation du seprateur */
    .results-separator {
      height: 1px;
      background: linear-gradient(to right, rgba(63, 81, 181, 0), rgba(63, 81, 181, 0.5), rgba(63, 81, 181, 0));
      margin: 20px 0;
      position: relative;
    }
    
    .results-separator::before {
      content: '';
      position: absolute;
      top: -5px;
      left: 50%;
      transform: translateX(-50%);
      width: 10px;
      height: 10px;
      background: #3f51b5;
      border-radius: 50%;
    }
  ")),
  
  # JavaScript pour améliorer les interactions
  tags$script(HTML("
    $(document).ready(function() {
      // Animation du téléchargement au survol
      $('.btn-download-pv').hover(
        function() {
          $(this).css('background', 'linear-gradient(135deg, #303f9f, #3f51b5)');
        },
        function() {
          $(this).css('background', 'linear-gradient(135deg, #3f51b5, #303f9f)');
        }
      );
      
      // Animation des filtres
      $('.position-filter-item').hover(
        function() {
          $(this).find('.form-check-label').css('color', '#3f51b5');
        },
        function() {
          $(this).find('.form-check-label').css('color', '');
        }
      );
      
      // Animation de l'entrée des résultats
      $('#results_chart').css('opacity', '0');
      setTimeout(function() {
        $('#results_chart').css({
          'transition': 'opacity 1s ease, transform 1s ease',
          'opacity': '1',
          'transform': 'translateY(0)'
        });
      }, 500);
    });
  ")),
  
  div(class = "results-main-card shadow",
    div(class = "results-header d-flex align-items-center",
      div(class = "icon-container",
        icon("trophy", class = "fa-2x text-white")
      ),
      h2("Résultats des élections", class = "mb-0 fw-bold")
    ),
    div(class = "results-body",
      div(class = "results-filters floating-results",
      fluidRow(
          column(6,
          # Cases à cocher pour filtrer les postes
          uiOutput("result_position_checkboxes")
        ),
          column(6, class = "d-flex align-items-center justify-content-end",
            downloadButton("downloadPV", "Télécharger le procès-verbal", 
              class = "btn-download-pv", icon = icon("file-pdf"))
          )
        )
      ),
      
      div(class = "results-separator"),
      
      div(class = "results-chart-container p-4", id = "results_chart_wrapper",
        plotOutput("results_chart", height = "450px")
      ),
      
      uiOutput("results_details")
    )
  ),
  
  # Bouton d'action flottant pour télécharger rapidement le PV
  div(class = "floating-action", id = "quick_download_button", title = "Télécharger le PV",
    icon("file-download")
  )
) 
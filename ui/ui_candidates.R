div(class = "candidates-page-modern",
  
  # Inclure les feuilles de style
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/candidates.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
  ),
  
  # Bannière Hero moderne et professionnelle
  div(class = "hero-banner-candidates",
    div(class = "hero-overlay"),
    div(class = "hero-particles"),
    div(class = "hero-content",
      div(class = "container",
        div(class = "row align-items-center",
          div(class = "col-lg-7",
            div(class = "hero-text",
              div(class = "hero-badge",
                icon("star", class = "me-2"),
                "Élections AES-ENSAE 2025"
              ),
              h1(class = "hero-title",
                span(class = "hero-title-main", "Découvrez nos"),
                span(class = "hero-title-highlight", "Candidats")
              ),
              p(class = "hero-subtitle", 
                "Explorez les profils des candidats passionnés qui aspirent à diriger notre association étudiante. Découvrez leurs visions, leurs programmes innovants et leurs engagements pour façonner l'avenir de l'AES-ENSAE-Sénégal."
              ),
              div(class = "hero-cta",
                actionButton("scroll_to_candidates", 
                  label = tagList(icon("arrow-down", class = "me-2"), "Explorer les candidats"),
                  class = "btn-hero-primary"
                )
              )
            )
          ),
          div(class = "col-lg-5",
            div(class = "hero-stats-section",
              div(class = "stats-header",
                h3(class = "stats-title", "Chiffres Clés"),
                p(class = "stats-subtitle", "Données en temps réel")
              ),
              div(class = "hero-stats-grid",
                div(class = "stat-card stat-primary",
                  div(class = "stat-icon",
                    icon("users", class = "stat-icon-element")
                  ),
                  div(class = "stat-content",
                    div(class = "stat-number", uiOutput("total_candidates_count", inline = TRUE)),
                    div(class = "stat-label", "Candidats"),
                    div(class = "stat-description", "Prêts à servir")
                  )
                ),
                div(class = "stat-card stat-secondary",
                  div(class = "stat-icon",
                    icon("briefcase", class = "stat-icon-element")
                  ),
                  div(class = "stat-content",
                    div(class = "stat-number", uiOutput("total_positions_count", inline = TRUE)),
                    div(class = "stat-label", "Postes"),
                    div(class = "stat-description", "À pourvoir")
                  )
                ),
                div(class = "stat-card stat-accent",
                  div(class = "stat-icon",
                    icon("layer-group", class = "stat-icon-element")
                  ),
                  div(class = "stat-content",
                    div(class = "stat-number", "2"),
                    div(class = "stat-label", "Catégories"),
                    div(class = "stat-description", "Organisées")
                  )
                )
              ),
              div(class = "hero-categories",
                div(class = "category-pill bureau-pill",
                  icon("crown", class = "me-2"),
                  "Bureau Exécutif"
                ),
                div(class = "category-pill dept-pill",
                  icon("building", class = "me-2"),
                  "Départements Permanents"
                ),
                div(class = "category-pill election-pill",
                  icon("vote-yea", class = "me-2"),
                  "Élections 2025"
                )
              )
            )
          )
        )
      )
    )
  ),
  
  # Section principale avec filtres et candidats
  div(class = "main-section",
    div(class = "container-fluid",
      div(class = "row",
        
        # Sidebar avec filtres sophistiqués
        div(class = "col-xl-3 col-lg-4",
          div(class = "filters-sidebar",
            
            # En-tête des filtres
            div(class = "filters-header",
              h4(class = "filters-title",
                icon("filter", class = "me-2"),
                "Filtres & Recherche"
              ),
              p(class = "filters-subtitle", "Affinez votre recherche")
            ),
            
            # Barre de recherche avancée
            div(class = "search-section",
              div(class = "search-wrapper",
                div(class = "search-input-group",
                  icon("search", class = "search-icon"),
                  div(class = "form-group",
                    tags$input(
                      type = "text",
                      id = "candidate_search",
                      class = "form-control search-input",
                      placeholder = "Rechercher un candidat..."
                    )
                  ),
                  actionButton("clear_search", 
                    icon("times"),
                    class = "clear-search-btn",
                    title = "Effacer la recherche"
                  )
                )
              )
    ),
    
            # Filtres par catégorie avec design moderne
            div(class = "category-filters",
              
              # Bureau Exécutif
              div(class = "filter-category-group",
                div(class = "category-header",
                  div(class = "category-icon-wrapper bureau-exec",
                    icon("crown", class = "category-icon")
                  ),
                  div(class = "category-info",
                    h5(class = "category-title", "Bureau Exécutif"),
                    p(class = "category-desc", "Postes de direction et coordination")
                  ),
                  actionButton("toggle_bureau", 
                    icon("chevron-down"),
                    class = "category-toggle"
                  )
                ),
                div(class = "category-content", id = "bureau-filters",
                  uiOutput("bureau_filters")
                )
              ),
              
              # Départements Permanents
              div(class = "filter-category-group",
                div(class = "category-header",
                  div(class = "category-icon-wrapper dept-perm",
                    icon("building", class = "category-icon")
                  ),
                  div(class = "category-info",
                    h5(class = "category-title", "Départements Permanents"),
                    p(class = "category-desc", "Postes spécialisés et clubs")
                  ),
                  actionButton("toggle_dept", 
                    icon("chevron-down"),
                    class = "category-toggle"
                  )
            ),
                div(class = "category-content", id = "dept-filters",
                  uiOutput("departements_filters")
                )
              )
            ),
            
            # Actions des filtres
            div(class = "filter-actions",
              actionButton("reset_all_filters", 
                label = tagList(icon("refresh", class = "me-2"), "Réinitialiser tout"),
                class = "btn btn-outline-secondary w-100 reset-btn"
              ),
              div(class = "active-filters-count",
                uiOutput("active_filters_display")
              )
            )
          )
        ),
        
        # Zone principale des candidats
        div(class = "col-xl-9 col-lg-8",
          div(class = "candidates-main-area",
            
            # Barre d'outils moderne
            div(class = "toolbar-modern",
              div(class = "toolbar-left",
                div(class = "results-info",
                  h3(class = "results-title", "Candidats"),
                  div(class = "results-meta",
                    span(class = "results-count", uiOutput("results_summary", inline = TRUE)),
                    span(class = "results-separator", "•"),
                    span(class = "last-updated", "Mis à jour aujourd'hui")
                  )
                )
              ),
              div(class = "toolbar-right",
                div(class = "view-controls-modern",
                  div(class = "view-toggle-group",
                    actionButton("grid_view", 
                      icon("th"),
                      class = "view-btn active",
                      title = "Vue grille"
                    ),
                    actionButton("list_view", 
                      icon("list"),
                      class = "view-btn",
                      title = "Vue liste"
                    ),
                    actionButton("card_view", 
                      icon("id-card"),
                      class = "view-btn",
                      title = "Vue cartes"
                    )
                  )
                ),
                div(class = "sort-controls",
                  div(class = "form-group",
                    tags$select(
                      id = "sort_by",
                      class = "form-control sort-select",
                      tags$option(value = "position", selected = "selected", "Par poste"),
                      tags$option(value = "name", "Ordre alphabétique"),
                      tags$option(value = "category", "Par catégorie")
                    )
                  )
                )
              )
            ),
            
            # Zone d'affichage des candidats
            div(class = "candidates-display-modern",
              uiOutput("candidates_cards")
            ),
            
            # Pagination (si nécessaire)
            div(class = "pagination-section",
              uiOutput("pagination_controls")
                )
              )
            )
          )
        )
      ),
      
  # Modal pour les détails du candidat
  div(id = "candidateModal", class = "modal fade", tabindex = "-1",
    div(class = "modal-dialog modal-lg modal-dialog-centered",
      div(class = "modal-content modern-modal",
        div(class = "modal-header",
          h4(class = "modal-title", id = "candidateModalTitle"),
          tags$button(type = "button", class = "btn-close", `data-bs-dismiss` = "modal")
        ),
        div(class = "modal-body",
          uiOutput("candidate_modal_content")
        ),
        div(class = "modal-footer",
          tags$button(type = "button", class = "btn btn-secondary", `data-bs-dismiss` = "modal", "Fermer"),
          uiOutput("candidate_modal_vote_btn")
        )
      )
    )
  ),
  
  # Scripts JavaScript pour les interactions
  tags$script(HTML("
    $(document).ready(function() {
      // Ouvrir les sections de filtres par défaut
      $('.category-content').show();
      $('.category-toggle i').removeClass('fa-chevron-down').addClass('fa-chevron-up');
      
      // Toggle des catégories de filtres
      $('.category-toggle').click(function() {
        var content = $(this).closest('.filter-category-group').find('.category-content');
        var icon = $(this).find('i');
        
        content.slideToggle(300);
        icon.toggleClass('fa-chevron-down fa-chevron-up');
      });
      
      // Animation des cartes au survol
      $(document).on('mouseenter', '.candidate-card-modern', function() {
        $(this).addClass('hovered');
      }).on('mouseleave', '.candidate-card-modern', function() {
        $(this).removeClass('hovered');
      });
      
      // Gestion des vues
      $('.view-btn').click(function() {
        $('.view-btn').removeClass('active');
        $(this).addClass('active');
      });
      
      // Animation de la bannière hero
      $('.floating-card').each(function(index) {
        $(this).css('animation-delay', (index * 0.2) + 's');
      });
      
      // Forcer le défilement sur les sections de contenu
      $('.category-content').css({
        'overflow-y': 'scroll',
        'max-height': '250px',
        'display': 'block'
      });
    });
  "))
) 
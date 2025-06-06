div(class = "container home-container",
  # Inclure la feuille de style externe
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/home.css")
  ),
  
  # JavaScript pour le centrage des éléments
  tags$script(HTML("
    $(document).ready(function() {
      // Assurer que les conteneurs sont bien centrés
      $('.home-container').css({
        'max-width': '1200px',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'width': '100%'
      });
      
      // Assurer que la bannière prend toute la largeur
      $('.home-banner').css('width', '100%');
      
      // Assurer que les rangées et colonnes sont correctement dimensionnées
      $('.row').css('width', '100%');
      
      // Amélioration de l'affichage des cartes
      $('.card').css({
        'width': '100%',
        'margin-bottom': '20px'
      });
      
      // Appliquer les styles lors du redimensionnement de la fenêtre
      $(window).resize(function() {
        $('.home-container, .home-banner, .row, .card').css('width', '100%');
      });
    });
  ")),
  
  div(class = "spacer", style = "height: 10px;"),
  
  
  # Section JavaScript pour les animations et effets
  tags$script(HTML("
    $(document).ready(function() {
      // Animation d'entrée pour les cartes
      $('.welcome-card').css({opacity: 0, transform: 'translateY(20px)'}).delay(300).animate({opacity: 1, transform: 'translateY(0px)'}, 800);
      
      // Animation en cascade pour les cartes
      $('.info-card').each(function(index) {
        $(this).css({opacity: 0, transform: 'translateY(20px)'})
          .delay(300 + (index * 150))
          .animate({opacity: 1, transform: 'translateY(0px)'}, 800);
      });
      
      // Effet de parallaxe pour la bannière
      $('.home-banner').mousemove(function(e) {
        var moveX = (e.pageX * -1 / 25);
        var moveY = (e.pageY * -1 / 25);
        $(this).css('background-position', moveX + 'px ' + moveY + 'px');
      });
      
      // Animation au survol pour les icônes
      $('.feature-icon').hover(
        function() {
          $(this).addClass('animate__animated animate__heartBeat');
        },
        function() {
          $(this).removeClass('animate__animated animate__heartBeat');
        }
      );
    });
  ")),
  
  # Styles CSS améliorés
  tags$style(HTML("
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
    
    .home-container {
      font-family: 'Poppins', sans-serif;
      padding-bottom: 50px;
      overflow-x: hidden;
    }
    
    /* Bannière améliorée */
    .home-banner {
      background-image: url('images/fond.png');
      background-size: cover;
      background-position: center;
      height: 400px;
      border-radius: 20px;
      position: relative;
      margin-bottom: 50px;
      overflow: hidden;
      transition: all 0.5s ease;
      box-shadow: 0 15px 30px rgba(0,0,0,0.2);
    }
    
    .home-banner:hover {
      transform: translateY(-5px);
      box-shadow: 0 20px 40px rgba(0,0,0,0.3);
    }
    
    .overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.4) 100%);
      border-radius: 20px;
    }
    
    .banner-content {
      position: relative;
      padding: 20px;
      color: white;
      text-align: center;
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      z-index: 2;
    }
    
    .banner-content h3 {
      font-size: 2.5rem;
      font-weight: 700;
      text-shadow: 0 2px 8px rgba(0,0,0,0.7);
      margin-bottom: 10px;
      color: white;
    }
    
    .banner-content p {
      font-size: 1.2rem;
      max-width: 700px;
      margin-bottom: 30px;
      text-shadow: 0 1px 3px rgba(0,0,0,0.5);
    }
    
    .aes-logo {
      height: 150px;
      border-radius: 15px;
      border: 5px solid rgba(255,255,255,0.8);
      box-shadow: 0 10px 25px rgba(0,0,0,0.3);
      margin-bottom: 20px;
      transition: all 0.5s ease;
      animation: float 6s ease-in-out infinite;
      z-index: 5;
    }
    
    @keyframes float {
      0% { transform: translateY(0px); }
      50% { transform: translateY(-15px); }
      100% { transform: translateY(0px); }
    }
    
    /* Cartes d'information améliorées */
    .card {
      border: none !important;
      border-radius: 20px !important;
      overflow: hidden;
      box-shadow: 0 10px 25px rgba(0,0,0,0.08) !important;
      transition: all 0.5s ease;
      height: 100%;
    }
    
    .card:hover {
      transform: translateY(-10px);
      box-shadow: 0 15px 35px rgba(0,0,0,0.15) !important;
    }
    
    .card-header {
      background: white !important;
      border-bottom: none !important;
      padding: 25px !important;
      position: relative;
    }
    
    .card-header::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(45deg, rgba(63, 81, 181, 0.05), transparent);
      z-index: 0;
    }
    
    .card-body {
      padding: 25px !important;
      position: relative;
      z-index: 1;
      background: linear-gradient(135deg, #fff, #f8f9fa);
    }
    
    .feature-icon {
      width: 60px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 15px;
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      color: white;
      margin-right: 20px;
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.2);
      transition: all 0.3s ease;
    }
    
    .feature-icon.orange {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.2);
    }
    
    .feature-icon.green {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.2);
    }
    
    .feature-icon.red {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.2);
    }
    
    .feature-icon.cyan {
      background: linear-gradient(135deg, #3f51b5, #303f9f);
      box-shadow: 0 8px 20px rgba(63, 81, 181, 0.2);
    }
    
    .card-title {
      font-weight: 700;
      font-size: 1.5rem;
      margin-bottom: 0;
      color: #333;
    }
    
    /* Documents et événements */
    .document-item, .event-item {
      padding: 15px;
      border-radius: 10px;
      transition: all 0.3s ease;
      margin-bottom: 15px;
      background: rgba(0,0,0,0.02);
    }
    
    .document-item:hover, .event-item:hover {
      background: rgba(0,0,0,0.04);
      transform: translateX(10px);
    }
    
    .document-item:last-child, .event-item:last-child {
      margin-bottom: 0;
    }
    
    /* Section contact */
    .contact-item {
      padding: 12px;
      border-radius: 8px;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
    }
    
    .contact-item:hover {
      background: rgba(0,0,0,0.03);
      transform: translateX(5px);
    }
    
    .social-icon {
      transition: all 0.3s ease;
      display: inline-block;
      text-decoration: none !important;
      border-bottom: none !important;
      outline: none !important;
    }
    
    .social-icon:hover {
      transform: translateY(-5px);
      text-decoration: none !important;
      border-bottom: none !important;
      outline: none !important;
    }
    
    /* Separateurs visuels */
    .visual-separator {
      position: relative;
      height: 1px;
      background: linear-gradient(to right, rgba(63, 81, 181, 0), rgba(63, 81, 181, 0.5), rgba(63, 81, 181, 0));
      margin: 40px 0;
    }
    
    .visual-separator::before {
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
    
    /* Media queries pour responsivité */
    @media (max-width: 768px) {
      .home-banner {
        height: 350px;
      }
      
      .banner-content h3 {
        font-size: 1.8rem;
      }
      
      .card {
        margin-bottom: 20px;
      }
      
      .feature-icon {
        width: 50px;
        height: 50px;
      }
    }
  ")),
  
  # Bannière améliorée
  div(class = "home-banner welcome-card", 
    div(class = "overlay"),
    div(class = "banner-content",
      img(src = "images/aes.jpg", class = "aes-logo", alt = "Logo AES"),
      h3("Amical des Elèves et Stagiaires de l'ENSAE", style = "font-size: 2.2rem; font-weight: 700; letter-spacing: 0.5px;"),
      p(class = "lead", "Plateforme électorale officielle pour façonner l'avenir de notre école ensemble")
    )
  ),
  
  # Section principale avec colonnes - Présentation et Mot du Président côte à côte
  fluidRow(class = "mb-5",
    # Présentation de l'AES
    column(6,
      div(class = "card info-card", style = "border-radius: 20px !important;",
        div(class = "card-header", 
          div(class = "d-flex align-items-center", 
            div(class = "feature-icon blue",
              icon("users", class = "fa-lg")
            ),
            h3(class = "card-title", "Présentation de l'AES")
          )
        ),
        div(class = "card-body",
          p(class = "lead", "Il est créé à Dakar le 09 mai 2009 une organisation dénommée Amicale des Etudiants et Stagiaires de l'ENSAE-Sénégal, en abrégé AES-ENSAE-Sénégal."),
          p("L'AES-ENSAE-Sénégal est une institution sans but lucratif, apolitique et non confessionnelle. Son siège se trouve à l'ENSAE-Sénégal."),
          p("L'AES-ENSAE-Sénégal constitue un cadre de rencontre et de concertation entre étudiants et stagiaires de l'ENSAE-Sénégal."),
          
          h4(class = "mt-4 mb-3", "Elle a pour but :"),
          div(class = "mission-items",
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("L'accueil et l'intégration des nouveaux étudiants")
            ),
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("La promotion d'un cadre d'étude et d'échange entre les étudiants de l'école")
            ),
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("La promotion de la solidarité entre les étudiants")
            ),
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("La promotion de l'école et du métier de statisticiens")
            ),
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("La promotion de l'unité entre les statisticiens")
            ),
            div(class = "d-flex align-items-center mb-3",
              div(style = "width: 30px; text-align: center; margin-right: 15px;",
                icon("check-circle", class = "text-primary")
              ),
              div("De travailler en étroite collaboration avec l'administration pour la bonne marche de l'école")
            )
          ),
          
          h4(class = "mt-4 mb-3", "Adhésion"),
          p("Est membre de l'AES-ENSAE-Sénégal tout étudiant ou stagiaire régulièrement inscrit pour une formation d'au moins six (6) mois à l'ENSAE-Sénégal.")
        )
      )
    ),
    
    # Mot du président
    column(6,
      div(class = "card info-card", style = "border-radius: 20px !important;",
        div(class = "card-header", 
          div(class = "d-flex align-items-center justify-content-between", 
          div(class = "d-flex align-items-center", 
              div(class = "feature-icon green",
                icon("quote-left", class = "fa-lg")
              ),
              h3(class = "card-title", "Mot du Président")
            ),
            div(class = "ms-auto", 
              img(src = "images/aes.jpg", height = "40px", class = "rounded", style = "border-radius: 10px; border: 2px solid white; box-shadow: 0 3px 10px rgba(0,0,0,0.1);")
            )
          )
        ),
        div(class = "card-body",
          div(class = "row",
            div(class = "col-md-3 text-center",
              div(style = "position: relative; margin-bottom: 15px;",
                img(src = "images/pr_BEN.jpg", alt = "Président de l'AES", width = "100%", 
                    class = "rounded", style = "border-radius: 15px; border: 4px solid white; box-shadow: 0 10px 20px rgba(0,0,0,0.1);"),
                div(style = "position: absolute; bottom: 0; right: 0; background: #4caf50; width: 25px; height: 25px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid white;",
                    icon("check", class = "text-white", style = "font-size: 12px;")
                )
              ),
              p(class = "fw-bold", "Président de l'AES")
            ),
            div(class = "col-md-9",
              div(style = "background-color: rgba(0,0,0,0.02); border-radius: 15px; padding: 15px; position: relative;",
                div(style = "position: absolute; top: -10px; left: 20px; font-size: 24px; color: #4caf50;",
                  icon("quote-left")
                ),
                p(class = "fst-italic mt-3", "\"Chers camarades élèves et stagiaires,\""),
              p("C'est avec un immense plaisir que je vous accueille sur la plateforme électorale de notre école. L'ENSAE est un lieu d'excellence où nous formons les futurs leaders dans le domaine de la statistique et de l'économie."),
              p("Notre amical travaille sans relâche pour enrichir votre expérience estudiantine et vous accompagner tout au long de votre parcours. Je vous invite à participer activement à cette élection qui définira l'avenir de notre communauté."),
              p("Ensemble, construisons une ENSAE plus forte et plus unie !"),
                p(class = "text-end fw-bold mt-3", "Le Président de l'AES")
              )
            )
          )
        )
      )
    )
  ),
  
  # Séparateur visuel amélioré
  div(class = "visual-separator"),
  
  # Section Documents utiles et Événements
  fluidRow(class = "mb-5",
    # Documents utiles
    column(6,
      div(class = "card info-card", style = "border-radius: 20px !important;",
        div(class = "card-header",
          div(class = "d-flex align-items-center", 
            div(class = "feature-icon orange",
              icon("file-alt", class = "fa-lg")
            ),
            h3(class = "card-title", "Documents utiles")
          )
        ),
        div(class = "card-body",
          div(class = "document-item d-flex align-items-center",
            div(class = "doc-icon me-3", style = "background-color: rgba(63, 81, 181, 0.1); width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;",
              icon("file-pdf", class = "text-primary fa-lg")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-1", "Règlement intérieur de l'ENSAE"),
              p(class = "mb-0 small text-muted", "Document officiel - PDF (1.2 MB)")
            ),
            div(
              tags$a(href = "#", download = TRUE, class = "btn btn-sm btn-outline-primary", icon("download"))
            )
          ),
          div(class = "document-item d-flex align-items-center",
            div(class = "doc-icon me-3", style = "background-color: rgba(63, 81, 181, 0.1); width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;",
              icon("file-pdf", class = "text-primary fa-lg")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-1", "Statuts de l'AES"),
              p(class = "mb-0 small text-muted", "Document officiel - PDF (222 KB)")
            ),
            div(
              tags$a(href = "statut_aes.pdf", download = "Statuts_AES_ENSAE.pdf", target = "_blank", class = "btn btn-sm btn-outline-primary", icon("download"))
            )
          ),
          div(class = "document-item d-flex align-items-center",
            div(class = "doc-icon me-3", style = "background-color: rgba(63, 81, 181, 0.1); width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;",
              icon("file-pdf", class = "text-primary fa-lg")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-1", "Guide de l'étudiant"),
              p(class = "mb-0 small text-muted", "Document officiel - PDF (3.4 MB)")
            ),
            div(
              tags$a(href = "#", download = TRUE, class = "btn btn-sm btn-outline-primary", icon("download"))
            )
          ),
          div(class = "document-item d-flex align-items-center",
            div(class = "doc-icon me-3", style = "background-color: rgba(63, 81, 181, 0.1); width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;",
              icon("file-pdf", class = "text-primary fa-lg")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-1", "Calendrier académique"),
              p(class = "mb-0 small text-muted", "Document officiel - PDF (1.5 MB)")
            ),
            div(
              tags$a(href = "#", download = TRUE, class = "btn btn-sm btn-outline-primary", icon("download"))
            )
          )
        )
      )
    ),
    
    # Événements à venir
    column(6,
      div(class = "card info-card", style = "border-radius: 20px !important;",
        div(class = "card-header",
          div(class = "d-flex align-items-center", 
            div(class = "feature-icon red",
              icon("calendar-alt", class = "fa-lg")
            ),
            h3(class = "card-title", "Événements à venir")
          )
        ),
        div(class = "card-body",
          div(class = "event-item d-flex align-items-start",
            div(class = "event-date me-3 text-center", style = "min-width: 60px; background: linear-gradient(to bottom, #3f51b5, #303f9f); color: white; padding: 10px; border-radius: 10px;",
              div(style = "font-size: 1.5rem; font-weight: 700;", "28"),
              div(style = "font-size: 0.8rem; text-transform: uppercase;", "Mai")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-2", "Assemblée Générale"),
              p(class = "mb-1 text-muted", icon("clock", class = "me-1"), "14h00 - Amphithéâtre Principal"),
              p(class = "mb-0 small", "Discussion des projets de l'AES et présentation des résultats des élections.")
            )
          ),
          div(class = "event-item d-flex align-items-start",
            div(class = "event-date me-3 text-center", style = "min-width: 60px; background: linear-gradient(to bottom, #3f51b5, #303f9f); color: white; padding: 10px; border-radius: 10px;",
              div(style = "font-size: 1.5rem; font-weight: 700;", "10"),
              div(style = "font-size: 0.8rem; text-transform: uppercase;", "Juin")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-2", "Journée culturelle"),
              p(class = "mb-1 text-muted", icon("clock", class = "me-1"), "10h00 - Campus ENSAE"),
              p(class = "mb-0 small", "Célébration de la diversité culturelle à travers des activités artistiques et culinaires.")
            )
          ),
          div(class = "event-item d-flex align-items-start",
            div(class = "event-date me-3 text-center", style = "min-width: 60px; background: linear-gradient(to bottom, #3f51b5, #303f9f); color: white; padding: 10px; border-radius: 10px;",
              div(style = "font-size: 1.5rem; font-weight: 700;", "25"),
              div(style = "font-size: 0.8rem; text-transform: uppercase;", "Juil")
            ),
            div(class = "flex-grow-1",
              h5(class = "mb-2", "Conférence annuelle"),
              p(class = "mb-1 text-muted", icon("clock", class = "me-1"), "09h30 - Salle de conférence"),
              p(class = "mb-0 small", "Intervenants de renom dans le domaine de la statistique et de l'économie.")
            )
          )
        )
      )
    )
  ),
  
  # Séparateur visuel amélioré
  div(class = "visual-separator"),
  
  # Section Nous contacter déplacée en bas avec design amélioré
  fluidRow(class = "mb-4",
    # Contacts et réseaux sociaux
    column(12,
      div(class = "card info-card", style = "border-radius: 20px !important;",
        div(class = "card-header",
          div(class = "d-flex align-items-center", 
            div(class = "feature-icon cyan",
              icon("address-book", class = "fa-lg")
            ),
            h3(class = "card-title", "Nous contacter")
          )
        ),
        div(class = "card-body",
          div(class = "row align-items-stretch",
            div(class = "col-md-4",
              div(class = "contact-section h-100 d-flex flex-column justify-content-center",
                div(class = "contact-item mb-3 d-flex align-items-center",
                  div(class = "icon-circle me-3", style = "background: linear-gradient(135deg, #4285f4, #34a853); width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(66, 133, 244, 0.3);",
                    icon("globe", class = "text-white fa-lg")
                ),
                div(class = "flex-grow-1",
                    h5(class = "mb-1 fw-bold", "Site web"),
                    tags$a(href = "https://www.ensae.sn/", target = "_blank", class = "text-primary text-decoration-none", "www.ensae.sn")
                )
              ),
                div(class = "contact-item mb-3 d-flex align-items-center",
                  div(class = "icon-circle me-3", style = "background: linear-gradient(135deg, #ea4335, #fbbc05); width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(234, 67, 53, 0.3);",
                    icon("envelope", class = "text-white fa-lg")
                ),
                div(class = "flex-grow-1",
                    h5(class = "mb-1 fw-bold", "Email"),
                    tags$a(href = "mailto:aesensaesn@gmail.com", class = "text-primary text-decoration-none", "aesensaesn@gmail.com")
                  )
                )
              )
            ),
            div(class = "col-md-4",
              div(class = "contact-section h-100 d-flex flex-column justify-content-center",
                div(class = "contact-item mb-3 d-flex align-items-center", 
                  div(class = "icon-circle me-3", style = "background: linear-gradient(135deg, #34a853, #0f9d58); width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(52, 168, 83, 0.3);",
                    icon("phone", class = "text-white fa-lg")
                ),
                div(class = "flex-grow-1",
                    h5(class = "mb-2 fw-bold", "Téléphone"),
                    p(class = "mb-1 text-muted", "+221 77 028 69 51"),
                    p(class = "mb-0 text-muted", "+221 78 109 18 22")
                  )
                )
              )
            ),
            div(class = "col-md-4",
              div(class = "contact-section h-100 d-flex flex-column justify-content-center text-center",
                h5(class = "mb-4 fw-bold", "Suivez-nous"),
                div(class = "social-icons d-flex justify-content-center gap-3",
                tags$a(href = "https://www.facebook.com/AesEnsae", target = "_blank", class = "social-icon",
                         style = "width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; border-radius: 15px; text-decoration: none; border: none; background: linear-gradient(135deg, #1877f2, #42a5f5); box-shadow: 0 4px 12px rgba(24, 119, 242, 0.3); transition: all 0.3s ease;",
                         icon("facebook", class = "fa-2x text-white")),
                tags$a(href = "https://www.linkedin.com/school/ensae", target = "_blank", class = "social-icon", 
                         style = "width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; border-radius: 15px; text-decoration: none; border: none; background: linear-gradient(135deg, #0077b5, #00a0dc); box-shadow: 0 4px 12px rgba(0, 119, 181, 0.3); transition: all 0.3s ease;",
                         icon("linkedin", class = "fa-2x text-white")),
                tags$a(href = "https://www.instagram.com/aes.ensae?igsh=cWRsYWVmemJ5ZGE3", target = "_blank", class = "social-icon",
                         style = "width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; border-radius: 15px; text-decoration: none; border: none; background: linear-gradient(135deg, #e4405f, #fd1d1d, #fcb045); box-shadow: 0 4px 12px rgba(228, 64, 95, 0.3); transition: all 0.3s ease;",
                         icon("instagram", class = "fa-2x text-white"))
                )
              )
            )
          )
        )
      )
    )
  )
) 
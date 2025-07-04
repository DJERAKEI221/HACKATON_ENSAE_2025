auth_ui_content <- function(ns) {
  tagList(
tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/auth.css"),
      tags$style(HTML("
        /* Styles améliorés pour l'authentification */
                 .fullscreen-auth {
           position: fixed;
           top: 0;
           left: 0;
           width: 100vw;
           height: 100vh;
           background: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.6)), 
                        url('images/fond.png') center/cover no-repeat;
           display: flex;
           align-items: flex-start;
           justify-content: center;
           z-index: 9999;
           overflow: visible;
           padding: 20px 20px 20px 20px;
         }
        
                 .auth-card-container {
           display: flex;
           align-items: center;
           justify-content: center;
           width: 100%;
           max-width: 650px;
           margin: 0 auto;
         }
         
         .auth-card {
           background: rgba(255, 255, 255, 0.95);
           backdrop-filter: blur(10px);
           border-radius: 20px;
           box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
           padding: 15px 35px;
           width: 100%;
           max-width: 580px;
           border: 1px solid rgba(255, 255, 255, 0.2);
           animation: slideIn 0.6s ease-out;
         }
        
        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateY(-30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        
                 .auth-card-header {
           text-align: center;
           margin-bottom: 8px;
         }
         
         .auth-card-header img {
           width: 40px;
           height: 40px;
           margin-bottom: 4px;
           border-radius: 0;
           border: none;
           box-shadow: none;
         }
         
         .ensae-motto {
           font-size: 14px;
           color: #1976d2;
           font-style: italic;
           margin-bottom: 4px;
           font-weight: 400;
         }
        
                 .alert-info {
           background: linear-gradient(135deg, #e3f2fd, #bbdefb);
           border: none;
           border-radius: 12px;
           color: #1565c0;
           font-size: 11px;
           padding: 4px 8px;
           margin-bottom: 0;
           box-shadow: 0 2px 8px rgba(21, 101, 192, 0.1);
         }
         
         .form-group {
           margin-bottom: 8px;
         }
        
        .form-label {
          font-weight: 600;
          color: #333;
          font-size: 13px;
          margin-bottom: 4px;
          display: block;
        }
        
                 .form-control, .form-select {
           border: 2px solid #e0e0e0;
           border-radius: 10px;
           padding: 8px 10px;
           font-size: 14px;
           transition: all 0.3s ease;
           background: rgba(255, 255, 255, 0.9);
         }
        
        .form-control:focus, .form-select:focus {
          border-color: #3f51b5;
          box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.1);
          background: white;
        }
        
                 .btn-access {
           background: linear-gradient(135deg, #3f51b5, #303f9f);
           border: none;
           border-radius: 12px;
           padding: 10px 18px;
           font-weight: 600;
           font-size: 15px;
           color: white;
           width: 100%;
           transition: all 0.3s ease;
           box-shadow: 0 4px 15px rgba(63, 81, 181, 0.3);
         }
        
        .btn-access:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(63, 81, 181, 0.4);
          background: linear-gradient(135deg, #303f9f, #283593);
        }
        
        .btn-access:active {
          transform: translateY(0);
        }
        
        .alert-success {
          background: linear-gradient(135deg, #e8f5e8, #c8e6c9);
          border: none;
          border-radius: 12px;
          color: #2e7d32;
          padding: 15px;
          margin-top: 20px;
          box-shadow: 0 2px 8px rgba(46, 125, 50, 0.1);
        }
        
        .auth-nav-buttons .btn {
          border-radius: 10px;
          padding: 10px 15px;
          font-size: 13px;
          font-weight: 500;
          margin-bottom: 8px;
          transition: all 0.3s ease;
        }
        
        .auth-nav-buttons .btn:hover {
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
                 .auth-card-footer {
           text-align: center;
           margin-top: 6px;
           padding-top: 6px;
           border-top: 1px solid rgba(0, 0, 0, 0.1);
         }
        
        .auth-card-footer p {
          font-size: 12px;
          color: #666;
          margin: 0;
        }
        
        /* Responsive */
        @media (max-width: 576px) {
          .auth-card {
            margin: 10px;
            padding: 25px 20px;
          }
          
          .auth-card-header img {
            width: 50px;
            height: 50px;
          }
          
          .form-control, .form-select {
            padding: 10px 12px;
            font-size: 13px;
          }
          
          .btn-access {
            padding: 12px 18px;
            font-size: 14px;
          }
        }
      "))
    ),

div(class = "fullscreen-auth",
  div(class = "auth-card-container",
    div(class = "auth-card",
          div(class = "auth-card-header",
            img(src = "images/ensae.png", alt = "ENSAE Logo"),
        div(class = "ensae-motto", 
          HTML('<div style="display:inline-flex; align-items:center; background:linear-gradient(90deg,#e3f0ff 0%,#f5faff 100%); padding:6px 16px 6px 10px; border-radius:14px; box-shadow:0 2px 8px rgba(63,81,181,0.07); font-size:1.08rem; font-weight:600; color:#2a3b6e; margin-bottom:2px; gap:7px;"><i class="fa fa-chart-line" style="color:#1976d2; font-size:1.2em; margin-right:6px;"></i>Statistiques en main, futur en vue</div>')
        ),
        div(class = "alert alert-info", 
              HTML("<div style='background: linear-gradient(90deg, #3f51b5 0%, #5a55ae 100%); padding: 12px 18px; border-radius: 18px; box-shadow: 0 4px 18px rgba(63,81,181,0.10); margin: 10px 0 10px 0; color: white; display: flex; align-items: center; white-space:nowrap;'>\n  <i class='fa fa-vote-yea me-3' style='font-size:2.2rem; color:#FFD700;'></i>\n  <span style='font-size:1.1rem; font-weight:700; letter-spacing:0.5px;'>Élection des membres du bureau de l'AES</span>\n</div>")
        )
      ),
      div(class = "auth-card-body",
             # Champ identifiant (toujours visible)
             div(class = "form-group",
               tags$label(HTML('<i class="fa fa-user-lock" style="color:#1976d2; margin-right:6px;"></i>Identifiant'), class = "form-label"),
               passwordInput(ns("accessCode"), NULL, 
                 placeholder = "Entrez votre code personnel",
                 width = "100%")
             ),
             
             # Champs cachés au début (nom, prénom, classe)
             hidden(
               div(id = ns("user_info_fields"),
                 div(class = "row g-3 mb-3",
                   div(class = "col-6",
              tags$label(HTML('<i class="fa fa-user" style="color:#1976d2; margin-right:6px;"></i>Nom'), class = "form-label"),
                     textInput(ns("lastName"), NULL, 
                       placeholder = "Votre nom de famille",
                width = "100%")
            ),
                   div(class = "col-6",
              tags$label(HTML('<i class="fa fa-id-card" style="color:#1976d2; margin-right:6px;"></i>Prénom'), class = "form-label"),
                     textInput(ns("firstName"), NULL, 
                       placeholder = "Votre prénom",
                       width = "100%")
                   )
                 ),
                 div(id = ns("studentYear_container"), class = "form-group",
                   tags$label(HTML('<i class="fa fa-graduation-cap" style="color:#1976d2; margin-right:6px;"></i>Classe'), class = "form-label"),
                   selectInput(ns("studentYear"), NULL, 
                     choices = c("Sélectionnez votre classe" = "", "AS1", "AS2", "AS3", "ISEP1", "ISEP2", "ISEP3", "ISE1 Maths", "ISE1 Eco","ISE2", "ISE3", "Master stats agricoles", "Master ADEP"),
                width = "100%")
            )
          )
        ),
            div(class = "d-grid",
              actionButton(ns("login"), "Accéder au système", 
            icon = icon("right-to-bracket"),
                class = "btn-access")
        ),
        hidden(
              div(id = ns("auth_success"), class = "alert alert-success",
            icon("check-circle"), 
            "Authentification réussie! Accès au système autorisé."
          )
        ),
        hidden(
                             div(id = ns("auth_nav_buttons"), class = "auth-nav-buttons mt-2",
                 h6("Naviguer vers:", class = "text-center mb-2"),
                 div(class = "row g-2",
                  div(class = "col-6",
                div(class = "d-grid",
                      actionButton(ns("goto_home"), "Accueil", 
                    icon = icon("home"),
                        class = "btn btn-info btn-sm")
                )
              ),
                  div(class = "col-6",
                div(class = "d-grid",
                      actionButton(ns("goto_candidates"), "Candidats", 
                    icon = icon("user-tie"),
                        class = "btn btn-primary btn-sm")
                )
              ),
                  div(class = "col-6",
                div(class = "d-grid",
                      actionButton(ns("goto_vote"), "Voter", 
                    icon = icon("check-to-slot"),
                        class = "btn btn-success btn-sm")
                )
              ),
                  div(class = "col-6",
                div(class = "d-grid",
                      actionButton(ns("goto_results"), "Résultats", 
                    icon = icon("chart-column"),
                        class = "btn btn-warning btn-sm")
                    )
                  )
                )
              )
            )
          ),
          div(class = "auth-card-footer",
            p("© ENSAE 2025 - Système électoral sécurisé")
          )
        )
      )
    )
  )
}
admin_ui <- function(id) {
  ns <- NS(id) # Utiliser cette fonction NS pour préfixer les IDs
  
  div(class = "admin-container",
      # Message pour les utilisateurs non-administrateurs (toujours visible au début)
      div(id = "student-access-content", class = "student-access-content",
          div(class = "alert alert-warning student-access-message", 
              style = "margin-bottom: 2rem; background: linear-gradient(135deg, #fff3e0, #ffe0b2); border-left: 4px solid #ff9800; border-radius: 8px;",
              div(style = "display: flex; align-items: center;",
                  icon("exclamation-triangle", class = "fa-2x", style = "color: #ff9800; margin-right: 1rem;"),
                  div(
                    h4("⚠️ Accès Administration Restreint", style = "color: #e65100; margin: 0 0 0.5rem 0; font-weight: bold;"),
                    p("Cette section est exclusivement réservée aux administrateurs du système électoral.", 
                      style = "margin: 0; color: #bf360c; font-weight: 500;"),
                    p("En tant qu'étudiant, vous avez accès aux sections : Candidats, Votes, Résultats et Statistiques.", 
                      style = "margin: 0.25rem 0 0 0; color: #bf360c; font-size: 0.9rem;")
                  )
              )
          ),
          
          # Guide de navigation pour les étudiants
          div(class = "student-guide", style = "margin-bottom: 2rem; padding: 1.5rem; background: linear-gradient(135deg, #e3f2fd, #bbdefb); border-radius: 8px; border-left: 4px solid #2196f3;",
              h5("📍 Où aller maintenant ?", style = "color: #0d47a1; margin-bottom: 1rem;"),
              div(class = "row",
                  div(class = "col-md-6",
                      tags$a(href = "#", onclick = "$('a[data-value=\"Candidats au scrutin AES\"]').click(); return false;",
                             style = "text-decoration: none; color: inherit;",
                             div(style = "margin-bottom: 1rem; cursor: pointer; padding: 0.5rem; border-radius: 4px; transition: background-color 0.3s;",
                                 onmouseover = "this.style.backgroundColor='rgba(33, 150, 243, 0.1)'",
                                 onmouseout = "this.style.backgroundColor='transparent'",
                                 icon("users", style = "color: #2196f3; margin-right: 0.5rem;"),
                                 strong("Candidats"), " - Découvrez les programmes"
                             )
                      ),
                      tags$a(href = "#", onclick = "$('a[data-value=\"Votes AES\"]').click(); return false;",
                             style = "text-decoration: none; color: inherit;",
                             div(style = "margin-bottom: 1rem; cursor: pointer; padding: 0.5rem; border-radius: 4px; transition: background-color 0.3s;",
                                 onmouseover = "this.style.backgroundColor='rgba(33, 150, 243, 0.1)'",
                                 onmouseout = "this.style.backgroundColor='transparent'",
                                 icon("vote-yea", style = "color: #2196f3; margin-right: 0.5rem;"),
                                 strong("Voter"), " - Exprimez votre choix"
                             )
                      )
                  ),
                  div(class = "col-md-6",
                      tags$a(href = "#", onclick = "$('a[data-value=\"Résultats\"]').click(); return false;",
                             style = "text-decoration: none; color: inherit;",
                             div(style = "margin-bottom: 1rem; cursor: pointer; padding: 0.5rem; border-radius: 4px; transition: background-color 0.3s;",
                                 onmouseover = "this.style.backgroundColor='rgba(33, 150, 243, 0.1)'",
                                 onmouseout = "this.style.backgroundColor='transparent'",
                                 icon("chart-column", style = "color: #2196f3; margin-right: 0.5rem;"),
                                 strong("Résultats"), " - Consultez les tendances"
                             )
                      ),
                      tags$a(href = "#", onclick = "$('a[data-value=\"Statistiques\"]').click(); return false;",
                             style = "text-decoration: none; color: inherit;",
                             div(style = "margin-bottom: 1rem; cursor: pointer; padding: 0.5rem; border-radius: 4px; transition: background-color 0.3s;",
                                 onmouseover = "this.style.backgroundColor='rgba(33, 150, 243, 0.1)'",
                                 onmouseout = "this.style.backgroundColor='transparent'",
                                 icon("chart-pie", style = "color: #2196f3; margin-right: 0.5rem;"),
                                 strong("Statistiques"), " - Analysez la participation"
                             )
                      )
                  )
              )
          ),
          
          # Message encourageant
          div(class = "alert alert-info", style = "background: linear-gradient(135deg, #e8f5e8, #c8e6c9); border-left: 4px solid #4caf50; border-radius: 8px;",
              div(style = "text-align: center;",
                  icon("heart", style = "color: #4caf50; margin-right: 0.5rem;"),
                  strong("Votre participation compte !"), 
                  p(style = "margin: 0.5rem 0 0 0; color: #2e7d32;", "Chaque vote contribue à façonner l'avenir de notre école.")
              )
          )
      ),
      
      # Contenu administrateur (masqué par défaut, révélé par JavaScript)
      div(id = "admin-content", class = "admin-content", style = "display: none;",
          # Message d'avertissement sécurité
          div(class = "alert alert-warning security-warning", style = "margin-bottom: 2rem; border-left: 4px solid #ff9800; background: linear-gradient(135deg, #fff3e0, #ffe0b2);",
              div(style = "display: flex; align-items: center;",
                  icon("exclamation-triangle", class = "fa-2x", style = "color: #ff9800; margin-right: 1rem;"),
                  div(
                    h4("🔒 Zone d'Administration Sécurisée", style = "color: #e65100; margin: 0 0 0.5rem 0; font-weight: bold;"),
                    p("Cette page est exclusivement réservée aux administrateurs autorisés du système électoral ENSAE.", 
                      style = "margin: 0; color: #bf360c; font-weight: 500;"),
                    p("Accès strictement contrôlé par authentification sécurisée.", 
                      style = "margin: 0.25rem 0 0 0; color: #bf360c; font-size: 0.9rem; font-style: italic;")
                  )
              )
          ),
          # JavaScript pour gérer l'affichage du contenu
          tags$script(HTML("
        $(document).ready(function() {
          console.log('=== PAGE ADMINISTRATION CHARGÉE ===');
          
          // Vérifier le statut admin et afficher le bon contenu
          function checkAdminStatus() {
            var isAdmin = $('input[name=\"user_is_admin\"]').val() === 'true';
            console.log('Statut admin détecté:', isAdmin);
            
            if (isAdmin) {
              $('#student-access-content').hide();
              $('#admin-content').show();
              console.log('Contenu administrateur affiché');
            } else {
              $('#student-access-content').show();
              $('#admin-content').hide();
              console.log('Contenu étudiant affiché');
            }
          }
          
          // Exécuter immédiatement
          checkAdminStatus();
          
          // Vérifier périodiquement au cas où le statut change
          setInterval(checkAdminStatus, 1000);
          
          console.log('====================================');
        });
      ")),
          
          # En-tête et styles améliorés
          tags$head(
            tags$style(HTML("
          .admin-container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 1.5rem;
            font-family: 'Poppins', sans-serif;
          }
          .admin-header {
            background: linear-gradient(135deg, #3f51b5, #1a237e);
            color: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            text-align: center;
            position: relative;
            overflow: hidden;
          }
          .admin-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1NiIgaGVpZ2h0PSIxMDAiPgo8cmVjdCB3aWR0aD0iNTYiIGhlaWdodD0iMTAwIiBmaWxsPSIjMzAzZjlmIj48L3JlY3Q+CjxwYXRoIGQ9Ik0yOCA2NkwwIDUwTDAgMTZMMjggMEw1NiAxNkw1NiA1MEwyOCA2NkwyOCAxMDAiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzFhMjM3ZSIgc3Ryb2tlLXdpZHRoPSIyIj48L3BhdGg+CjxwYXRoIGQ9Ik0yOCAwTDI4IDY2TDAgNTBMMCA1MEwyOCA2NkwiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzI4M2E5YSIgc3Ryb2tlLXdpZHRoPSIxIj48L3BhdGg+Cjwvc3ZnPg==');
            opacity: 0.2;
          }
          .admin-title {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            position: relative;
          }
          .admin-subtitle {
            font-size: 1.1rem;
            font-weight: 400;
            opacity: 0.9;
            margin-bottom: 0;
            position: relative;
          }
          .admin-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
            padding: 2rem;
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 0, 0, 0.05);
          }
          .admin-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
          }
          .admin-card h3 {
            color: #303f9f;
            font-size: 1.6rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid rgba(63, 81, 181, 0.1);
          }
          .admin-warning {
            background: linear-gradient(135deg, #ffebee, #ffcdd2);
            border-left: 4px solid #f44336;
            color: #b71c1c;
            padding: 1.2rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
          }
          .admin-warning i {
            font-size: 1.5rem;
            margin-right: 1rem;
          }
          .admin-form-group {
            margin-bottom: 2rem;
          }
          .admin-form-label {
            font-weight: 600;
            color: #424242;
            margin-bottom: 0.5rem;
            display: block;
          }
          .admin-form-control {
            border: 2px solid #e0e6ff;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
          }
          .admin-form-control:focus {
            border-color: #3f51b5;
            box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.15);
          }
          .admin-btn {
            font-weight: 600;
            padding: 0.8rem 2rem;
            border-radius: 8px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
          }
          .admin-btn-danger {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
            cursor: pointer;
            opacity: 1;
            pointer-events: auto;
          }
          .admin-btn-danger:hover {
            background: linear-gradient(135deg, #d32f2f, #b71c1c);
            box-shadow: 0 6px 15px rgba(244, 67, 54, 0.4);
            transform: translateY(-2px);
          }
          .admin-btn-info {
            background: linear-gradient(135deg, #2196f3, #1976d2);
            color: white;
            box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
            cursor: pointer;
            opacity: 1;
            pointer-events: auto;
          }
          .admin-btn-info:hover {
            background: linear-gradient(135deg, #1976d2, #0d47a1);
            box-shadow: 0 6px 15px rgba(33, 150, 243, 0.4);
            transform: translateY(-2px);
          }
          .admin-btn i {
            margin-right: 0.5rem;
            font-size: 1.1rem;
          }
          .admin-footer {
            text-align: center;
            margin-top: 3rem;
            font-size: 0.9rem;
            color: #757575;
          }
          .admin-footer a {
            color: #3f51b5;
            text-decoration: none;
          }
          
          /* Style pour le champ de confirmation */
          #reset_confirmation {
            border: 2px solid #e0e6ff;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
          }
          
          #reset_confirmation:focus {
            border-color: #3f51b5;
            box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.15);
            outline: none;
          }
          
          .admin-action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
          }
          
          .admin-card-section {
            margin-bottom: 1.5rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
          }
          
          .admin-card-section:last-child {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
          }
          
          /* Override bootstrap pour les boutons Shiny */
          .btn-lg {
            padding: 0.8rem 2rem;
            font-size: 1.1rem;
            border-radius: 8px;
            font-weight: 600;
          }
          
          .btn-danger {
            background-color: #f44336;
            border-color: #f44336;
          }
          
          .btn-danger:hover {
            background-color: #d32f2f;
            border-color: #d32f2f;
          }
          
          .btn-info {
            background-color: #2196f3;
            border-color: #2196f3;
          }
          
          .btn-info:hover {
            background-color: #1976d2;
            border-color: #1976d2;
          }
        "))
          ),
          
          # En-tête redessiné
          div(class = "admin-header",
              h1("🔐 Centre d'Administration", class = "admin-title"),
              p("Gestion et maintenance du système électoral", class = "admin-subtitle"),
              div(style = "margin-top: 1rem; padding: 0.5rem 1rem; background: rgba(255,255,255,0.2); border-radius: 20px; display: inline-block;",
                  icon("check-circle", style = "margin-right: 0.5rem;"),
                  "Zone sécurisée - Authentification vérifiée"
              )
          ),
          
          # Module d'annonces
          announcementSystemUI("announcements"),
          
          # Carte principale simplifiée
          div(class = "admin-card",
              # Section d'exportation (maintenant en premier)
              div(class = "admin-card-section",
                  h4("Exportation des données", 
                     tags$i(class = "fas fa-download", style = "margin-left: 10px; font-size: 1rem;")),
                  
                  p("Téléchargez l'ensemble des données de vote au format CSV pour les analyser dans d'autres applications."),
                  
                  div(class = "text-center mt-3",
                      downloadButton(ns("export_votes"), "Exporter tous les votes", 
                                     class = "btn btn-info btn-lg",
                                     icon = icon("file-export"))
                  )
              ),
              
              # Section de réinitialisation (maintenant en second)
              div(class = "admin-card-section",
                  # Avertissement
                  div(class = "admin-warning",
                      tags$i(class = "fas fa-exclamation-triangle"),
                      div(
                        strong("Attention : Action irréversible"),
                        p(style = "margin-bottom: 0;", 
                          "Cette action supprimera tous les votes enregistrés dans la base de données. Cette opération est irréversible.")
                      )
                  ),
                  
                  # Confirmation
                  div(class = "admin-form-group",
                      tags$label("Confirmation de sécurité :", class = "admin-form-label"),
                      div(class = "mb-1", "Pour confirmer, tapez votre ", strong("identifiant administrateur"), " dans le champ ci-dessous :"),
                      textInput(ns("reset_confirmation"), NULL, 
                                placeholder = "Votre identifiant", 
                                width = "100%")
                  ),
                  
                  # Bouton de réinitialisation
                  div(class = "text-center mt-4",
                      actionButton(ns("reset_system"), "Procéder à la réinitialisation", 
                                   class = "btn btn-danger btn-lg",
                                   icon = icon("exclamation-triangle"))
                  )
              )
          ),
          
          # Pied de page
          div(class = "admin-footer",
              p("Système d'administration • Élections ENSAE 2025", 
                br(),
                "Utilisez cet outil avec précaution")
          )
      ) # Fermeture du div admin-content
  )
} 
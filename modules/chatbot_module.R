# modules/chatbot_module.R - Module Chatbot Électoral IA

# Interface utilisateur du chatbot
chatbotUI <- function(id) {
  ns <- NS(id)
  
  div(id = ns("chatbot_container"), class = "chatbot-container",
    # Bouton pour ouvrir/fermer le chatbot
    div(id = ns("chatbot_toggle"), class = "chatbot-toggle",
      icon("comments", class = "fa-lg"),
      span("Assistant IA", class = "chatbot-label")
    ),
    
    # Interface du chatbot
    div(id = ns("chatbot_interface"), class = "chatbot-interface", style = "display: none;",
      # En-tête du chatbot
      div(class = "chatbot-header",
        div(class = "chatbot-title",
          icon("robot", class = "me-2"),
          "Assistant Électoral IA"
        ),
        div(class = "chatbot-status online",
          icon("circle", class = "fa-xs me-1"),
          "En ligne"
        ),
        div(id = ns("chatbot_close"), class = "chatbot-close",
          icon("times")
        )
      ),
      
      # Zone de conversation
      div(id = ns("chatbot_messages"), class = "chatbot-messages",
        div(class = "message bot-message",
          div(class = "message-avatar",
            icon("robot")
          ),
          div(class = "message-content",
            "👋 Bonjour ! Je suis votre assistant électoral IA. Comment puis-je vous aider aujourd'hui ?",
            br(),
            br(),
            "Vous pouvez me poser des questions sur :",
            br(),
            "• Les candidats et leurs programmes",
            br(),
            "• La procédure de vote",
            br(),
            "• Les résultats et statistiques",
            br(),
            "• L'AES et ses missions"
          ),
          div(class = "message-time",
            format(Sys.time(), "%H:%M")
          )
        )
      ),
      
      # Zone de saisie
      div(class = "chatbot-input-area",
        div(class = "input-group",
          textInput(ns("message_input"), 
                   label = NULL,
                   placeholder = "Tapez votre question ici...",
                   width = "100%"),
          div(class = "input-group-append",
            actionButton(ns("send_message"), "",
                        icon = icon("paper-plane"),
                        class = "btn btn-primary send-btn")
          )
        ),
        div(class = "quick-actions",
          actionButton(ns("btn_candidats"), "Candidats", class = "btn btn-sm btn-outline-primary quick-btn"),
          actionButton(ns("btn_vote"), "Comment voter", class = "btn btn-sm btn-outline-primary quick-btn"),
          actionButton(ns("btn_resultats"), "Résultats", class = "btn btn-sm btn-outline-primary quick-btn")
        )
      ),
      
      # Zone d'affichage dynamique pour les messages R
      uiOutput(ns("chatbot_r_messages"))
    ),
    
    # Styles CSS
    tags$style(HTML("
      /* Bouton toggle du chatbot */
      .chatbot-toggle {
        position: fixed;
        bottom: 120px;
        right: 20px;
        background: linear-gradient(135deg, #28a745, #20c997);
        color: white;
        border: none;
        border-radius: 50px;
        padding: 15px 20px;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(40, 167, 69, 0.3);
        transition: all 0.3s ease;
        z-index: 1024;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
        font-size: 0.9rem;
        user-select: none;
      }
      
      .chatbot-toggle:hover {
        background: linear-gradient(135deg, #20c997, #17a2b8);
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 6px 25px rgba(40, 167, 69, 0.4);
      }
      
      .chatbot-label {
        font-size: 0.85rem;
        white-space: nowrap;
      }
      
      /* Interface du chatbot */
      .chatbot-interface {
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 380px;
        height: 500px;
        background: white;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
        z-index: 1030;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        animation: slideIn 0.3s ease-out;
      }
      
      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateY(20px) scale(0.95);
        }
        to {
          opacity: 1;
          transform: translateY(0) scale(1);
        }
      }
      
      /* En-tête du chatbot */
      .chatbot-header {
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top-left-radius: 20px;
        border-top-right-radius: 20px;
      }
      
      .chatbot-title {
        font-weight: 600;
        font-size: 1rem;
        display: flex;
        align-items: center;
      }
      
      .chatbot-status {
        font-size: 0.8rem;
        display: flex;
        align-items: center;
      }
      
      .chatbot-status.online {
        color: #4caf50;
      }
      
      .chatbot-close {
        cursor: pointer;
        padding: 5px;
        border-radius: 50%;
        transition: background-color 0.2s;
      }
      
      .chatbot-close:hover {
        background-color: rgba(255, 255, 255, 0.2);
      }
      
      /* Zone de messages */
      .chatbot-messages {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
        background: #f8f9fa;
        display: flex;
        flex-direction: column;
        gap: 15px;
      }
      
      .message {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        max-width: 90%;
      }
      
      .bot-message {
        align-self: flex-start;
      }
      
      .user-message {
        align-self: flex-end;
        flex-direction: row-reverse;
      }
      
      .message-avatar {
        width: 35px;
        height: 35px;
        border-radius: 50%;
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 0.8rem;
        flex-shrink: 0;
      }
      
      .user-message .message-avatar {
        background: linear-gradient(135deg, #28a745, #20c997);
      }
      
      .message-content {
        background: white;
        padding: 12px 15px;
        border-radius: 18px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        font-size: 0.9rem;
        line-height: 1.4;
        position: relative;
      }
      
      .user-message .message-content {
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
      }
      
      .message-time {
        font-size: 0.7rem;
        color: #666;
        margin-top: 5px;
        text-align: center;
      }
      
      /* Zone de saisie */
      .chatbot-input-area {
        padding: 15px 20px;
        background: white;
        border-top: 1px solid #e9ecef;
      }
      
      .input-group {
        display: flex;
        gap: 10px;
        margin-bottom: 10px;
      }
      
      .chatbot-input-area input {
        border: 2px solid #e9ecef;
        border-radius: 25px;
        padding: 10px 15px;
        font-size: 0.9rem;
        transition: border-color 0.2s;
      }
      
      .chatbot-input-area input:focus {
        border-color: #3f51b5;
        box-shadow: none;
      }
      
      .send-btn {
        border-radius: 50%;
        width: 45px;
        height: 45px;
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .send-btn:hover {
        background: linear-gradient(135deg, #303f9f, #1a237e);
        transform: scale(1.05);
      }
      
      /* Actions rapides */
      .quick-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
      }
      
      .quick-btn {
        font-size: 0.75rem;
        padding: 5px 12px;
        border-radius: 15px;
        border: 1px solid #3f51b5;
        color: #3f51b5;
        background: transparent;
        transition: all 0.2s;
      }
      
      .quick-btn:hover {
        background: #3f51b5;
        color: white;
        transform: translateY(-2px);
      }
      
      /* Version mobile */
      @media (max-width: 768px) {
        .chatbot-toggle {
          bottom: 100px;
          right: 15px;
          padding: 12px 16px;
        }
        
        .chatbot-interface {
          width: calc(100vw - 20px);
          height: 70vh;
          right: 10px;
          bottom: 10px;
        }
        
        .chatbot-label {
          display: none;
        }
      }
    ")),
    
    # JavaScript pour l'interaction
    tags$script(HTML(paste0("
      $(document).ready(function() {
        // Base de connaissances du chatbot
        var knowledgeBase = {
          candidats: {
            keywords: ['candidat', 'postulant', 'qui', 'présente', 'liste'],
            responses: [
              'Voici les candidats pour les différents postes de l\'AES. Pour voir tous les candidats, consultez l\'onglet \"Candidats au scrutin AES\".',
              'Chaque candidat a un profil détaillé avec ses propositions et son expérience. Vous pouvez filtrer les candidats par poste.',
              'Les candidats se présentent pour différents postes : Président, Vice-Président, Secrétaire Général, etc.'
            ]
          },
          vote: {
            keywords: ['voter', 'comment', 'procédure', 'vote', 'bulletin'],
            responses: [
              'Pour voter, rendez-vous dans l\'onglet \"Votes AES\" après vous être authentifié.',
              'Le vote est anonyme et sécurisé. Vous ne pouvez voter qu\'une seule fois par poste.',
              'Sélectionnez votre candidat préféré et confirmez votre choix. Votre vote est immédiatement enregistré.'
            ]
          },
          resultats: {
            keywords: ['résultat', 'gagnant', 'vainqueur', 'score', 'dépouillement'],
            responses: [
              'Les résultats sont disponibles en temps réel dans l\'onglet \"Résultats\".',
              'Le dépouillement est automatique et transparent. Les statistiques détaillées sont dans l\'onglet \"Statistiques\".',
              'Les résultats finaux seront annoncés officiellement à la fin du scrutin.'
            ]
          },
          aes: {
            keywords: ['aes', 'amicale', 'association', 'organisation'],
            responses: [
              'L\'AES (Amicale des Étudiants et Stagiaires) représente tous les étudiants de l\'ENSAE.',
              'Créée en 2009, l\'AES promeut la solidarité et l\'entraide entre étudiants.',
              'L\'AES organise des activités culturelles, sportives et académiques.'
            ]
          },
          aide: {
            keywords: ['aide', 'help', 'assistance', 'problème'],
            responses: [
              'Je suis votre assistant électoral IA. Posez-moi vos questions !',
              'Vous pouvez me demander des informations sur les candidats, le vote, ou les résultats.',
              'Tapez \"candidats\", \"vote\", \"résultats\" ou \"aide\" pour des informations spécifiques.'
            ]
          }
        };
        
        var chatbotOpen = false;
        
        // Ouvrir/fermer le chatbot
        $('#", ns("chatbot_toggle"), "').click(function() {
          var interface = $('#", ns("chatbot_interface"), "');
          if (chatbotOpen) {
            interface.hide();
            chatbotOpen = false;
          } else {
            interface.show();
            chatbotOpen = true;
            var messages = $('#", ns("chatbot_messages"), "');
            messages.scrollTop(messages[0].scrollHeight);
          }
        });
        
        // Fermer le chatbot
        $('#", ns("chatbot_close"), "').click(function() {
          $('#", ns("chatbot_interface"), "').hide();
          chatbotOpen = false;
        });
        
        // Fonction pour ajouter un message
        function addMessage(content, isUser = false) {
          var messagesContainer = $('#", ns("chatbot_messages"), "');
          var time = new Date().toLocaleTimeString('fr-FR', {hour: '2-digit', minute:'2-digit'});
          var messageClass = isUser ? 'user-message' : 'bot-message';
          var avatarIcon = isUser ? 'fa-user' : 'fa-robot';
          
          var messageHtml = 
            '<div class=\"message ' + messageClass + '\">' +
              '<div class=\"message-avatar\">' +
                '<i class=\"fa ' + avatarIcon + '\"></i>' +
              '</div>' +
              '<div class=\"message-content\">' +
                content +
              '</div>' +
              '<div class=\"message-time\">' +
                time +
              '</div>' +
            '</div>';
          
          messagesContainer.append(messageHtml);
          messagesContainer.scrollTop(messagesContainer[0].scrollHeight);
        }
        
        // Fonction IA pour générer une réponse
        function generateAIResponse(userMessage) {
          var message = userMessage.toLowerCase();
          var bestMatch = null;
          var maxScore = 0;
          
          Object.keys(knowledgeBase).forEach(function(category) {
            var keywords = knowledgeBase[category].keywords;
            var score = 0;
            
            keywords.forEach(function(keyword) {
              if (message.includes(keyword)) {
                score += 1;
              }
            });
            
            if (score > maxScore) {
              maxScore = score;
              bestMatch = category;
            }
          });
          
          if (bestMatch && maxScore > 0) {
            var responses = knowledgeBase[bestMatch].responses;
            return responses[Math.floor(Math.random() * responses.length)];
          } else {
            var defaultResponses = [
              'Je ne suis pas sûr de comprendre votre question. Pouvez-vous la reformuler ?',
              'Pouvez-vous préciser votre question ? Je peux vous aider sur les candidats, le vote, ou les résultats.',
              'Tapez \"aide\" pour voir ce que je peux faire pour vous.'
            ];
            return defaultResponses[Math.floor(Math.random() * defaultResponses.length)];
          }
        }
        
        // Envoyer un message
        function sendMessage() {
          var input = $('#", ns("message_input"), "');
          var message = input.val().trim();
          
          if (message) {
            addMessage(message, true);
            input.val('');
            
            setTimeout(function() {
              var response = generateAIResponse(message);
              addMessage(response, false);
            }, 800 + Math.random() * 1200);
          }
        }
        
        // Événements
        $('#", ns("send_message"), "').click(sendMessage);
        
        $('#", ns("message_input"), "').keypress(function(e) {
          if (e.which == 13) {
            sendMessage();
          }
        });
        
        // Boutons d'action rapide
        $('#", ns("btn_candidats"), "').click(function() {
          addMessage('Candidats', true);
          setTimeout(function() {
            addMessage(generateAIResponse('candidats'), false);
          }, 500);
        });
        
        $('#", ns("btn_vote"), "').click(function() {
          addMessage('Comment voter ?', true);
          setTimeout(function() {
            addMessage(generateAIResponse('comment voter'), false);
          }, 500);
        });
        
        $('#", ns("btn_resultats"), "').click(function() {
          addMessage('Résultats', true);
          setTimeout(function() {
            addMessage(generateAIResponse('résultats'), false);
          }, 500);
        });
      });
    ")))
  )
}

# Serveur du chatbot avec fonctionnalités innovantes
chatbotServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Historique des messages (pour affichage)
    messages <- reactiveVal(list(
      list(sender = "bot", text = "👋 Bonjour ! Je suis votre assistant électoral IA. Comment puis-je vous aider aujourd'hui ?<br><br><b>Vous pouvez me demander :</b><br>• Les candidats et leurs programmes<br>• La procédure de vote<br>• Les résultats et statistiques<br>• L'AES et ses missions<br><button id='btn_discover' class='btn btn-sm btn-outline-success mt-2'>Découvrir la plateforme</button>")
    ))

    # Base FAQ dynamique (en mémoire)
    faq_db <- reactiveVal(list(
      "comment voter" = "Pour voter, allez dans l'onglet <b>Votes AES</b> et suivez les instructions.",
      "candidats" = "La liste des candidats est disponible dans l'onglet <b>Candidats au scrutin AES</b>.",
      "statut" = "<a href='Documentation/statut_aes.pdf' target='_blank'>Télécharger le statut de l'AES</a>",
      "règlement" = "<a href='Documentation/Reglement_interieur_ENSAE_janvier_2021.pdf' target='_blank'>Télécharger le règlement intérieur</a>"
    ))

    # Fonction pour ajouter un message
    add_message <- function(sender, text) {
      old <- messages()
      messages(append(old, list(list(sender = sender, text = text))))
    }

    # Affichage dynamique des messages
    output$chatbot_r_messages <- renderUI({
      lapply(messages(), function(msg) {
        div(class = if (msg$sender == "user") "message user-message" else "message bot-message",
            div(class = "message-avatar", icon(if (msg$sender == "user") "user" else "robot")),
            div(class = "message-content", HTML(msg$text)),
            div(class = "message-time", format(Sys.time(), "%H:%M"))
        )
      })
    })

    # Fonction de recherche intelligente et FAQ
    get_bot_response <- function(user_text) {
      txt <- tolower(user_text)
      # Recherche intelligente dans la FAQ
      for (q in names(faq_db())) {
        if (grepl(q, txt, fixed = TRUE)) return(faq_db()[[q]])
      }
      # Recherche de mots-clés pour les documents
      if (grepl("programme", txt)) {
        return("Pour voir les programmes des candidats, allez dans l'onglet <b>Candidats au scrutin AES</b>.")
      }
      # Mode découverte
      if (grepl("découvrir", txt) || grepl("tour", txt)) {
        return(paste0(
          "<b>Tour guidé de la plateforme :</b><br>",
          "1. <b>Accueil</b> : Retrouvez les documents utiles et les annonces importantes.<br>",
          "2. <b>Candidats</b> : Consultez la liste des candidats et leurs programmes.<br>",
          "3. <b>Votes AES</b> : Participez au vote en toute sécurité.<br>",
          "4. <b>Résultats</b> : Suivez les résultats en temps réel.<br>",
          "5. <b>Statistiques</b> : Analysez la participation et les tendances.<br>"
        ))
      }
      # Si rien trouvé
      return("Je n'ai pas encore la réponse à cette question. Tapez 'aide' pour voir ce que je peux faire, ou posez une question sur les élections, les candidats, le vote...")
    }

    # Gestion de l'envoi de message utilisateur (à adapter selon ton UI)
    observeEvent(input$message_input, {
      req(input$message_input)
      user_msg <- input$message_input
      add_message("user", user_msg)
      # Réponse du bot
      bot_msg <- get_bot_response(user_msg)
      add_message("bot", bot_msg)
      updateTextInput(session, "message_input", value = "")
    }, ignoreInit = TRUE)

    # Gestion du bouton Découvrir la plateforme (si cliqué)
    observe({
      session$sendCustomMessage('bindDiscoverBtn', list(ns = ns(NULL)))
    })
    observeEvent(input$btn_discover, {
      add_message("bot", get_bot_response("découvrir"))
    })
  })
} 
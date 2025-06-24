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
      

      
      /* Styles du chatbot améliorés avec design premium */
      .chatbot-toggle {
        position: fixed;
        bottom: 120px;
        right: 20px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #667eea 100%);
        color: white;
        border: none;
        border-radius: 50px;
        padding: 16px 28px;
        cursor: pointer;
        box-shadow: 
          0 12px 40px rgba(102, 126, 234, 0.3),
          0 4px 15px rgba(102, 126, 234, 0.2),
          inset 0 1px 0 rgba(255, 255, 255, 0.3);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        z-index: 9999;
        display: flex;
        align-items: center;
        gap: 12px;
        font-weight: 700;
        font-size: 0.95rem;
        user-select: none;
        backdrop-filter: blur(20px) saturate(180%);
        border: 2px solid rgba(255, 255, 255, 0.2);
        position: relative;
        overflow: hidden;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        font-family: 'Poppins', sans-serif;
      }
      
      .chatbot-toggle::before {
        content: '';
        position: absolute;
        top: -2px;
        left: -100%;
        width: 100%;
        height: calc(100% + 4px);
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
        transition: left 0.8s ease-in-out;
        border-radius: inherit;
      }
      
      .chatbot-toggle::after {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
        transition: all 0.6s ease;
        transform: translate(-50%, -50%);
        border-radius: 50%;
      }
      
      .chatbot-toggle:hover::before {
        left: 100%;
      }
      
      .chatbot-toggle:hover::after {
        width: 100px;
        height: 100px;
      }
      
      .chatbot-toggle:hover {
        background: linear-gradient(135deg, #764ba2 0%, #667eea 50%, #764ba2 100%);
        transform: translateY(-8px) scale(1.05) rotate(2deg);
        box-shadow: 
          0 20px 60px rgba(102, 126, 234, 0.4),
          0 8px 25px rgba(102, 126, 234, 0.3),
          inset 0 1px 0 rgba(255, 255, 255, 0.4);
      }
      
      .chatbot-toggle:active {
        transform: translateY(-4px) scale(1.02);
        transition: all 0.1s ease;
      }
      
      .chatbot-toggle.pulse {
        animation: chatbotPulse 3s infinite, float 4s ease-in-out infinite;
      }
      
      @keyframes chatbotPulse {
        0% { 
          box-shadow: 
            0 12px 40px rgba(102, 126, 234, 0.3),
            0 4px 15px rgba(102, 126, 234, 0.2),
            inset 0 1px 0 rgba(255, 255, 255, 0.3);
        }
        50% { 
          box-shadow: 
            0 15px 50px rgba(102, 126, 234, 0.5),
            0 0 0 15px rgba(102, 126, 234, 0.1),
            0 0 0 30px rgba(102, 126, 234, 0.05),
            inset 0 1px 0 rgba(255, 255, 255, 0.4);
        }
        100% { 
          box-shadow: 
            0 12px 40px rgba(102, 126, 234, 0.3),
            0 4px 15px rgba(102, 126, 234, 0.2),
            inset 0 1px 0 rgba(255, 255, 255, 0.3);
        }
      }
      
      @keyframes float {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        25% { transform: translateY(-3px) rotate(1deg); }
        50% { transform: translateY(-6px) rotate(0deg); }
        75% { transform: translateY(-3px) rotate(-1deg); }
      }
      
      .chatbot-label {
        font-size: 0.85rem;
        white-space: nowrap;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        position: relative;
        z-index: 2;
        font-weight: 800;
        letter-spacing: 1px;
      }
      
      .chatbot-icon-container {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2;
      }
      
      .chatbot-main-icon {
        position: relative;
        z-index: 3;
        filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
        animation: iconPulse 2s ease-in-out infinite alternate;
        color: white;
        font-size: 1.2rem !important;
      }
      
      .chatbot-emoji {
        position: absolute;
        top: -8px;
        right: -8px;
        font-size: 1rem;
        z-index: 4;
        animation: emojiFloat 3s ease-in-out infinite;
        background: linear-gradient(135deg, #FFD700, #FFA500);
        border-radius: 50%;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
        border: 2px solid white;
      }
      
      @keyframes iconPulse {
        from { 
          filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
          transform: scale(1);
        }
        to { 
          filter: drop-shadow(0 2px 8px rgba(255, 255, 255, 0.6));
          transform: scale(1.1);
        }
      }
      
      @keyframes emojiFloat {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        33% { transform: translateY(-2px) rotate(5deg); }
        66% { transform: translateY(2px) rotate(-5deg); }
      }
      
      .chatbot-toggle:hover .chatbot-main-icon {
        animation: iconSpin 0.6s ease-in-out;
        color: #FFD700;
      }
      
      .chatbot-toggle:hover .chatbot-emoji {
        animation: emojiExcite 0.6s ease-in-out infinite;
        background: linear-gradient(135deg, #FF6B6B, #FF8E53);
      }
      
      @keyframes iconSpin {
        0% { transform: scale(1) rotate(0deg); }
        50% { transform: scale(1.2) rotate(180deg); }
        100% { transform: scale(1.1) rotate(360deg); }
      }
      
      @keyframes emojiExcite {
        0%, 100% { transform: translateY(0px) scale(1); }
        50% { transform: translateY(-3px) scale(1.2); }
      }
      
      .chatbot-interface {
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 420px;
        height: 580px;
        background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
        border-radius: 25px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15), 
                    0 0 0 1px rgba(255, 255, 255, 0.1);
        z-index: 1030;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        animation: chatbotSlideIn 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.2);
      }
      
      @keyframes chatbotSlideIn {
        from {
          opacity: 0;
          transform: translateY(30px) scale(0.9) rotateY(10deg);
        }
        to {
          opacity: 1;
          transform: translateY(0) scale(1) rotateY(0deg);
        }
      }
      
      .chatbot-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 18px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top-left-radius: 25px;
        border-top-right-radius: 25px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(102, 126, 234, 0.2);
      }
      
      .chatbot-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
        animation: headerShine 3s ease-in-out infinite;
      }
      
      @keyframes headerShine {
        0%, 100% { transform: translateX(-100%); }
        50% { transform: translateX(100%); }
      }
      
      .chatbot-title {
        font-weight: 700;
        font-size: 1.1rem;
        display: flex;
        align-items: center;
        position: relative;
        z-index: 1;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
      }
      
      .chatbot-title i {
        margin-right: 10px;
        animation: robotBlink 2s ease-in-out infinite;
      }
      
      @keyframes robotBlink {
        0%, 90%, 100% { transform: scale(1); }
        95% { transform: scale(1.1); }
      }
      
      .chatbot-status {
        font-size: 0.8rem;
        display: flex;
        align-items: center;
        position: relative;
        z-index: 1;
        opacity: 0.9;
        font-weight: 500;
      }
      
      .chatbot-status.online {
        color: #4ade80;
      }
      
      .chatbot-status.online i {
        animation: statusPulse 1.5s ease-in-out infinite;
      }
      
      @keyframes statusPulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
      }
      
      .chatbot-close {
        cursor: pointer;
        padding: 8px;
        border-radius: 50%;
        transition: all 0.3s ease;
        position: relative;
        z-index: 1;
        background: rgba(255, 255, 255, 0.1);
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .chatbot-close:hover {
        background: rgba(255, 255, 255, 0.2);
        transform: rotate(90deg) scale(1.1);
      }
      
      .chatbot-messages {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background: linear-gradient(145deg, #f8fafc 0%, #e2e8f0 100%);
        display: flex;
        flex-direction: column;
        gap: 18px;
        position: relative;
      }
      
      .chatbot-messages::-webkit-scrollbar {
        width: 6px;
      }
      
      .chatbot-messages::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.1);
        border-radius: 3px;
      }
      
      .chatbot-messages::-webkit-scrollbar-thumb {
        background: linear-gradient(135deg, #667eea, #764ba2);
        border-radius: 3px;
      }
      
      .message {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        max-width: 85%;
        animation: messageSlide 0.5s ease-out;
      }
      
      @keyframes messageSlide {
        from {
          opacity: 0;
          transform: translateY(20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      .bot-message {
        align-self: flex-start;
      }
      
      .user-message {
        align-self: flex-end;
        flex-direction: row-reverse;
      }
      
      .message-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea, #764ba2);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 0.9rem;
        flex-shrink: 0;
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        border: 2px solid rgba(255, 255, 255, 0.2);
      }
      
      .user-message .message-avatar {
        background: linear-gradient(135deg, #10b981, #059669);
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
      }
      
      .message-content {
        background: white;
        padding: 16px 20px;
        border-radius: 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        font-size: 0.95rem;
        line-height: 1.5;
        position: relative;
        border: 1px solid rgba(0, 0, 0, 0.05);
      }
      
      .bot-message .message-content::before {
        content: '';
        position: absolute;
        left: -8px;
        top: 15px;
        width: 0;
        height: 0;
        border-style: solid;
        border-width: 8px 8px 8px 0;
        border-color: transparent white transparent transparent;
      }
      
      .user-message .message-content {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
      }
      
      .user-message .message-content::before {
        content: '';
        position: absolute;
        right: -8px;
        top: 15px;
        width: 0;
        height: 0;
        border-style: solid;
        border-width: 8px 0 8px 8px;
        border-color: transparent transparent transparent #764ba2;
      }
      
      .message-time {
        font-size: 0.75rem;
        color: #64748b;
        margin-top: 8px;
        text-align: center;
        font-weight: 500;
      }
      
      .typing-indicator {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 12px 16px;
        background: white;
        border-radius: 20px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }
      
      .typing-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #667eea;
        animation: typingBounce 1.5s ease-in-out infinite;
      }
      
      .typing-dot:nth-child(2) { animation-delay: 0.2s; }
      .typing-dot:nth-child(3) { animation-delay: 0.4s; }
      
      @keyframes typingBounce {
        0%, 60%, 100% { transform: translateY(0); }
        30% { transform: translateY(-10px); }
      }
      
      .chatbot-input-area {
        padding: 20px 24px;
        background: white;
        border-top: 1px solid #e2e8f0;
        position: relative;
      }
      
      .chatbot-input-area::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: linear-gradient(90deg, transparent, #667eea, transparent);
      }
      
      .input-group {
        display: flex;
        gap: 12px;
        margin-bottom: 12px;
        position: relative;
      }
      
      .chatbot-input-area input {
        border: 2px solid #e2e8f0;
        border-radius: 30px;
        padding: 14px 20px;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: #f8fafc;
        box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
      }
      
      .chatbot-input-area input:focus {
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        background: white;
        transform: translateY(-1px);
      }
      
      .send-btn {
        border-radius: 50%;
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
      }
      
      .send-btn:hover {
        background: linear-gradient(135deg, #764ba2, #667eea);
        transform: scale(1.1) rotate(15deg);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
      }
      
      .send-btn:active {
        transform: scale(0.95);
      }
      
      .quick-actions {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
      }
      
      .quick-btn {
        font-size: 0.8rem;
        padding: 8px 16px;
        border-radius: 20px;
        border: 2px solid #667eea;
        color: #667eea;
        background: transparent;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        font-weight: 500;
        position: relative;
        overflow: hidden;
      }
      
      .quick-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #667eea, #764ba2);
        transition: left 0.3s ease;
        z-index: -1;
      }
      
      .quick-btn:hover {
        color: white;
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
      }
      
      .quick-btn:hover::before {
        left: 0;
      }
      
      .suggestion-chips {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        margin-top: 12px;
      }
      
      .suggestion-chip {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
        border: 1px solid #cbd5e1;
        border-radius: 16px;
        padding: 6px 14px;
        font-size: 0.8rem;
        color: #475569;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      
      .suggestion-chip:hover {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        transform: translateY(-2px);
      }
      
      @media (max-width: 768px) {
        .chatbot-toggle {
          bottom: 100px;
          right: 15px;
          padding: 16px 20px;
        }
        
        .chatbot-interface {
          width: calc(100vw - 20px);
          height: 75vh;
          right: 10px;
          bottom: 10px;
          border-radius: 20px;
        }
        
        .chatbot-header {
          border-top-left-radius: 20px;
          border-top-right-radius: 20px;
        }
        
        .chatbot-label {
          display: none;
        }
        
        .message {
          max-width: 90%;
        }
      }
    }
  ")),
    
    # JavaScript du chatbot amélioré et sophistiqué
    tags$script(HTML("
    $(document).ready(function() {
      // Base de connaissances améliorée du chatbot
      var knowledgeBase = {
        candidats: {
          keywords: ['candidat', 'postulant', 'qui', 'présente', 'liste', 'nom', 'profil'],
          responses: [
            '🗳️ **Candidats aux élections AES**\\n\\nVous pouvez consulter la liste complète des candidats dans l\\'onglet \"Candidats au scrutin AES\". Chaque candidat a un profil détaillé avec ses propositions et son expérience.',
            '👥 **Liste des candidats**\\n\\nLes candidats se présentent pour différents postes :\\n• Président\\n• Vice-Président\\n• Secrétaire Général\\n• Trésorier\\n• Commissaires aux comptes',
            '📋 **Profils détaillés**\\n\\nChaque candidat présente son programme et ses objectifs. Utilisez les filtres pour voir les candidats par poste spécifique.'
          ],
          suggestions: ['Voir tous les candidats', 'Postes disponibles', 'Programmes des candidats']
        },
        vote: {
          keywords: ['voter', 'comment', 'procédure', 'vote', 'bulletin', 'élection'],
          responses: [
            '🗳️ **Procédure de vote**\\n\\n1. Connectez-vous à votre compte\\n2. Allez dans l\\'onglet \"Votes AES\"\\n3. Sélectionnez votre candidat\\n4. Confirmez votre choix\\n\\n⚠️ Attention : Une seule vote par poste !',
            '🔒 **Vote sécurisé**\\n\\nLe système de vote est :\\n• Anonyme et confidentiel\\n• Sécurisé par authentification\\n• Traçable et transparent\\n• Accessible 24h/24',
            '✅ **Validation du vote**\\n\\nAprès avoir voté :\\n• Vous recevrez une confirmation\\n• Votre vote est immédiatement comptabilisé\\n• Vous ne pourrez plus modifier votre choix'
          ],
          suggestions: ['Comment voter', 'Sécurité du vote', 'Horaires de vote']
        },
        resultats: {
          keywords: ['résultat', 'gagnant', 'vainqueur', 'score', 'dépouillement', 'statistique'],
          responses: [
            '📊 **Résultats en temps réel**\\n\\nConsultez les résultats dans l\\'onglet \"Résultats\". Le dépouillement est automatique et les chiffres sont mis à jour en continu.',
            '🏆 **Statistiques détaillées**\\n\\nDans l\\'onglet \"Statistiques\", vous trouverez :\\n• Taux de participation\\n• Répartition des votes\\n• Graphiques interactifs\\n• Analyses par poste',
            '⏰ **Publication officielle**\\n\\nLes résultats finaux seront annoncés officiellement à la clôture du scrutin avec proclamation des élus.'
          ],
          suggestions: ['Voir les résultats', 'Taux de participation', 'Graphiques']
        },
        aes: {
          keywords: ['aes', 'amicale', 'association', 'organisation', 'ensae', 'école'],
          responses: [
            '🏫 **L\\'AES-ENSAE**\\n\\nL\\'Amicale des Étudiants et Stagiaires de l\\'ENSAE-Sénégal est une organisation créée en 2009. Elle représente tous les étudiants et promeut la solidarité.',
            '🎯 **Missions de l\\'AES**\\n\\n• Accueil et intégration des nouveaux\\n• Promotion d\\'un cadre d\\'étude\\n• Solidarité entre étudiants\\n• Collaboration avec l\\'administration\\n• Organisation d\\'événements',
            '📅 **Histoire et valeurs**\\n\\nDepuis 2009, l\\'AES est une institution apolitique et non confessionnelle qui œuvre pour l\\'excellence académique et l\\'épanouissement étudiant.'
          ],
          suggestions: ['Mission de l\\'AES', 'Histoire', 'Activités']
        },
        aide: {
          keywords: ['aide', 'help', 'assistance', 'problème', 'question'],
          responses: [
            '🤖 **Assistant IA à votre service !**\\n\\nJe suis là pour vous aider avec :\\n• Les candidats et leurs programmes\\n• La procédure de vote\\n• Les résultats et statistiques\\n• L\\'AES et ses missions',
            '💡 **Comment puis-je vous aider ?**\\n\\nTapez simplement votre question ou utilisez les boutons rapides ci-dessous. Je comprends le français et peux vous donner des informations précises.',
            '📚 **Ressources disponibles**\\n\\nJe peux vous orienter vers :\\n• La documentation officielle\\n• Les contacts utiles\\n• Les procédures détaillées\\n• Les FAQ'
          ],
          suggestions: ['Poser une question', 'FAQ', 'Contacts']
        },
        contact: {
          keywords: ['contact', 'téléphone', 'email', 'adresse', 'joindre'],
          responses: [
            '📧 **Nous contacter**\\n\\n• Email : aesensaesn@gmail.com\\n• Téléphone : +221 77 028 69 51\\n• Site web : www.ensae.sn\\n• Campus ENSAE-Sénégal',
            '🌐 **Réseaux sociaux**\\n\\nSuivez-nous sur :\\n• Facebook : AesEnsae\\n• LinkedIn : ENSAE\\n• Instagram : @aes.ensae\\n\\nPour des infos et actualités !',
          ],
          suggestions: ['Email', 'Téléphone', 'Réseaux sociaux']
        }
      };
      
      var chatbotOpen = false;
      var messageHistory = [];
      var isTyping = false;
      
      // Animation du bouton toggle
      function startPulseAnimation() {
        $('#chatbot_toggle').addClass('pulse');
      }
      
      function stopPulseAnimation() {
        $('#chatbot_toggle').removeClass('pulse');
      }
      
      // Démarrer l'animation après 3 secondes
      setTimeout(startPulseAnimation, 3000);
      
      // Ouvrir/fermer le chatbot avec animation améliorée
      $('#chatbot_toggle').click(function() {
        stopPulseAnimation();
        var interface = $('#chatbot_interface');
        if (chatbotOpen) {
          interface.fadeOut(300);
          chatbotOpen = false;
        } else {
          interface.fadeIn(400);
          chatbotOpen = true;
          var messages = $('#chatbot_messages');
          setTimeout(function() {
            messages.scrollTop(messages[0].scrollHeight);
          }, 100);
        }
      });
      
      // Fermer le chatbot
      $('#chatbot_close').click(function() {
        $('#chatbot_interface').fadeOut(300);
        chatbotOpen = false;
      });
      
      // Indicateur de frappe
      function showTypingIndicator() {
        if (isTyping) return;
        isTyping = true;
        
        var typingHtml = 
          '<div class=\"message bot-message typing-message\">' +
            '<div class=\"message-avatar\">' +
              '<i class=\"fa fa-robot\"></i>' +
            '</div>' +
            '<div class=\"typing-indicator\">' +
              '<div class=\"typing-dot\"></div>' +
              '<div class=\"typing-dot\"></div>' +
              '<div class=\"typing-dot\"></div>' +
            '</div>' +
          '</div>';
        
        $('#chatbot_messages').append(typingHtml);
        scrollToBottom();
      }
      
      function hideTypingIndicator() {
        $('.typing-message').remove();
        isTyping = false;
      }
      
      // Scroll automatique
      function scrollToBottom() {
        var messages = $('#chatbot_messages');
        messages.animate({ scrollTop: messages[0].scrollHeight }, 300);
      }
      
      // Fonction pour ajouter un message avec animation
      function addMessage(content, isUser = false, showSuggestions = false, suggestions = []) {
        hideTypingIndicator();
        
        var messagesContainer = $('#chatbot_messages');
        var time = new Date().toLocaleTimeString('fr-FR', {hour: '2-digit', minute:'2-digit'});
        var messageClass = isUser ? 'user-message' : 'bot-message';
        var avatarIcon = isUser ? 'fa-user' : 'fa-robot';
        
        // Formatage du contenu avec markdown simple
        var formattedContent = content
          .replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>')
          .replace(/\\n/g, '<br>');
        
        var messageHtml = 
          '<div class=\"message ' + messageClass + '\">' +
            '<div class=\"message-avatar\">' +
              '<i class=\"fa ' + avatarIcon + '\"></i>' +
            '</div>' +
            '<div class=\"message-content\">' +
              formattedContent +
            '</div>' +
            '<div class=\"message-time\">' +
              time +
            '</div>' +
          '</div>';
        
        messagesContainer.append(messageHtml);
        
        // Ajouter les suggestions si disponibles
        if (showSuggestions && suggestions.length > 0) {
          var suggestionsHtml = '<div class=\"suggestion-chips\">';
          suggestions.forEach(function(suggestion) {
            suggestionsHtml += '<span class=\"suggestion-chip\" onclick=\"handleSuggestionClick(\\'' + suggestion + '\\')\">📝 ' + suggestion + '</span>';
          });
          suggestionsHtml += '</div>';
          messagesContainer.append(suggestionsHtml);
        }
        
        // Stocker dans l'historique
        messageHistory.push({content: content, isUser: isUser, time: time});
        
        scrollToBottom();
      }
      
      // Gestion des clics sur suggestions
      window.handleSuggestionClick = function(suggestion) {
        $('.suggestion-chips').remove();
        addMessage(suggestion, true);
        
        setTimeout(function() {
          showTypingIndicator();
          setTimeout(function() {
            var response = generateAIResponse(suggestion);
            addMessage(response.text, false, true, response.suggestions);
          }, 1500 + Math.random() * 1000);
        }, 300);
      };
      
      // Fonction IA améliorée pour générer une réponse
      function generateAIResponse(userMessage) {
        var message = userMessage.toLowerCase();
        var bestMatch = null;
        var maxScore = 0;
        
        // Recherche avec scoring amélioré
        Object.keys(knowledgeBase).forEach(function(category) {
          var keywords = knowledgeBase[category].keywords;
          var score = 0;
          
          keywords.forEach(function(keyword) {
            if (message.includes(keyword)) {
              score += keyword.length; // Score pondéré par la longueur du mot-clé
            }
          });
          
          if (score > maxScore) {
            maxScore = score;
            bestMatch = category;
          }
        });
        
        if (bestMatch && maxScore > 0) {
          var categoryData = knowledgeBase[bestMatch];
          var responses = categoryData.responses;
          var suggestions = categoryData.suggestions || [];
          
          return {
            text: responses[Math.floor(Math.random() * responses.length)],
            suggestions: suggestions
          };
        } else {
          var defaultResponses = [
            '🤔 **Je ne suis pas sûr de comprendre...**\\n\\nPouvez-vous reformuler votre question ? Je peux vous aider sur les candidats, le vote, les résultats ou l\\'AES.',
            '💭 **Précisez votre demande**\\n\\nJe suis spécialisé dans :\\n• Les informations sur les candidats\\n• La procédure de vote\\n• Les résultats électoraux\\n• L\\'AES et ses missions',
            '🎯 **Suggestions d\\'aide**\\n\\nUtilisez les boutons rapides ci-dessous ou tapez \"aide\" pour voir toutes mes fonctionnalités.'
          ];
          
          return {
            text: defaultResponses[Math.floor(Math.random() * defaultResponses.length)],
            suggestions: ['Aide', 'Candidats', 'Vote', 'Résultats']
          };
        }
      }
      
      // Envoyer un message avec améliorations
      function sendMessage() {
        var input = $('#message_input');
        var message = input.val().trim();
        
        if (message) {
          addMessage(message, true);
          input.val('');
          
          // Délai réaliste pour la réponse
          setTimeout(function() {
            showTypingIndicator();
            setTimeout(function() {
              var response = generateAIResponse(message);
              addMessage(response.text, false, true, response.suggestions);
            }, 1200 + Math.random() * 1500);
          }, 400);
        }
      }
      
      // Événements améliorés
      $('#send_message').click(sendMessage);
      
      $('#message_input').keypress(function(e) {
        if (e.which == 13) {
          sendMessage();
        }
      });
      
      // Auto-focus sur l'input quand le chatbot s'ouvre
      $('#chatbot_toggle').click(function() {
        if (!chatbotOpen) {
          setTimeout(function() {
            $('#message_input').focus();
          }, 500);
        }
      });
      
      // Boutons d'action rapide améliorés
      $('#btn_candidats').click(function() {
        addMessage('👥 Candidats', true);
        setTimeout(function() {
          showTypingIndicator();
          setTimeout(function() {
            var response = generateAIResponse('candidats');
            addMessage(response.text, false, true, response.suggestions);
          }, 800);
        }, 300);
      });
      
      $('#btn_vote').click(function() {
        addMessage('🗳️ Comment voter ?', true);
        setTimeout(function() {
          showTypingIndicator();
          setTimeout(function() {
            var response = generateAIResponse('comment voter');
            addMessage(response.text, false, true, response.suggestions);
          }, 800);
        }, 300);
      });
      
      $('#btn_resultats').click(function() {
        addMessage('📊 Résultats', true);
        setTimeout(function() {
          showTypingIndicator();
          setTimeout(function() {
            var response = generateAIResponse('résultats');
            addMessage(response.text, false, true, response.suggestions);
          }, 800);
        }, 300);
      });
      

      // Fonctionnalités supplémentaires
      
      // Réponses contextuelles basées sur l'heure
      function getTimeBasedGreeting() {
        return '✨ Bonjour !';
      }
      
             // Message de bienvenue amélioré
       function updateWelcomeMessage() {
         var welcomeMsg = $('#chatbot_messages .message:first .message-content div:first');
         if (welcomeMsg.length > 0) {
           var greeting = getTimeBasedGreeting();
                             welcomeMsg.find('div:first').text(greeting + ' Je suis sunuAES');
         }
       }
       
       // Initialisation
       setTimeout(updateWelcomeMessage, 1000);
      
      // Détection d'inactivité pour relancer l'animation
      var inactivityTimer;
      function resetInactivityTimer() {
        clearTimeout(inactivityTimer);
        inactivityTimer = setTimeout(function() {
          if (!chatbotOpen) {
            startPulseAnimation();
          }
        }, 30000); // 30 secondes d'inactivité
      }
      
             $(document).on('click keypress', resetInactivityTimer);
       resetInactivityTimer();
       
       // Gérer l'affichage du bouton local vs global
       if ($('#chatbot_toggle_global').length > 0) {
         // Si le bouton global existe, on utilise le global
         $('#chatbot_toggle').hide();
       } else {
         // Sinon, on affiche le bouton local
         $('#chatbot_toggle').show();
       }
    });
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
                                        img(src = "images/president.jpg", alt = "Président de l'AES", width = "100%", 
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
                                        p("C'est avec un immense plaisir que je vous accueille sur la plateforme électorale de notre école. L'ENSAE est un lieu d'excellence pour la formation dans le domaine de la statistique et de l'économie."),
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
                                  tags$a(href = "../Documentation/Reglement_interieur_ENSAE_janvier_2021.pdf", download = "Reglement_interieur_ENSAE_janvier_2021.pdf", target = "_blank", class = "btn btn-sm btn-outline-primary", icon("download"))
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
                                    div(style = "font-size: 1.5rem; font-weight: 700;", "21"),
                                    div(style = "font-size: 0.8rem; text-transform: uppercase;", "Déc")
                                ),
                                div(class = "flex-grow-1",
                                    h5(class = "mb-2", "Journée d'intégration"),
                                    p(class = "mb-1 text-muted", icon("clock", class = "me-1"), "A l'amphi")
                                )
                            ),
                            div(class = "event-item d-flex align-items-start",
                                div(class = "event-date me-3 text-center", style = "min-width: 60px; background: linear-gradient(to bottom, #3f51b5, #303f9f); color: white; padding: 10px; border-radius: 10px;",
                                    div(style = "font-size: 1.5rem; font-weight: 700;", "28"),
                                    div(style = "font-size: 0.8rem; text-transform: uppercase;", "Juin")
                                ),
                                div(class = "flex-grow-1",
                                    h5(class = "mb-2", "Diner de Gala et Remise des Awards"),
                                    p(class = "mb-1 text-muted", icon("clock", class = "me-1"), "Centre culturel régional Blaise Senghor")
                                )
                            ),
                            
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
    ),
    
    # Séparateur avant le chatbot
    div(class = "chatbot-separator", style = "height: 60px; background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1)); margin: 40px 0 30px 0; border-radius: 15px; display: flex; align-items: center; justify-content: center;",
        div(style = "color: #667eea; font-weight: 600; font-size: 1.1rem; text-align: center;",
            icon("robot", class = "me-2", style = "font-size: 1.3rem; color: #764ba2;"),
            "Besoin d'aide ? Discutez avec sunuAES, notre assistant intelligent !"
        )
    ),
    
    # Chatbot électoral IA intégré
    div(id = "chatbot_container", class = "chatbot-container",
        # Bouton pour ouvrir/fermer le chatbot (caché si global présent)
        tags$button(id = "chatbot_toggle", class = "chatbot-toggle", style = "display: block;",
                    div(class = "chatbot-icon-container",
                        icon("comments", class = "fa-lg chatbot-main-icon"),
                        span("💬", class = "chatbot-emoji")
                    ),
                    span("sunuAES Assistant", class = "chatbot-label")
        ),
        
        # Interface du chatbot
        div(id = "chatbot_interface", class = "chatbot-interface", style = "display: none;",
            # En-tête du chatbot
            div(class = "chatbot-header",
                tags$button(id = "chatbot_close", class = "chatbot-close",
                            icon("times")
                )
            ),
            
            # Zone de conversation
            div(id = "chatbot_messages", class = "chatbot-messages",
                div(class = "message bot-message",
                    div(class = "message-avatar",
                        icon("robot")
                    ),
                    div(class = "message-content",
                        div(style = "text-align: center; margin-bottom: 15px;",
                            div(style = "font-size: 1.1rem; font-weight: 600; color: #667eea; margin-bottom: 5px;", "✨ Bonjour ! Je suis sunuAES"),
                            div(style = "font-size: 0.9rem; color: #64748b;", "Assistant Intelligent pour les Élections AES")
                        ),
                        div(style = "background: linear-gradient(135deg, #f8fafc, #e2e8f0); padding: 15px; border-radius: 12px; margin: 10px 0;",
                            div(style = "font-weight: 600; color: #334155; margin-bottom: 10px;", "🎯 Je peux vous aider avec :"),
                            div(style = "display: grid; gap: 8px;",
                                div(style = "display: flex; align-items: center; gap: 8px;",
                                    span(style = "color: #667eea;", "👥"), 
                                    span("Les candidats et leurs programmes")
                                ),
                                div(style = "display: flex; align-items: center; gap: 8px;",
                                    span(style = "color: #667eea;", "🗳️"), 
                                    span("La procédure de vote détaillée")
                                ),
                                div(style = "display: flex; align-items: center; gap: 8px;",
                                    span(style = "color: #667eea;", "📊"), 
                                    span("Les résultats et statistiques")
                                ),
                                div(style = "display: flex; align-items: center; gap: 8px;",
                                    span(style = "color: #667eea;", "🏫"), 
                                    span("L'AES et ses missions")
                                )
                            )
                        ),
                        div(style = "text-align: center; font-size: 0.9rem; color: #64748b; font-style: italic;",
                            "Posez-moi vos questions ou utilisez les boutons ci-dessous !"
                        )
                    ),
                    div(class = "message-time",
                        format(Sys.time(), "%H:%M")
                    )
                )
            ),
            
            # Zone de saisie
            div(class = "chatbot-input-area",
                div(class = "input-group",
                    tags$input(id = "message_input", 
                               type = "text",
                               class = "form-control",
                               placeholder = "Tapez votre question ici..."),
                    div(class = "input-group-append",
                        tags$button(id = "send_message", class = "btn btn-primary send-btn",
                                    icon("paper-plane"))
                    )
                ),
                div(class = "quick-actions",
                    tags$button(id = "btn_candidats", class = "btn btn-sm btn-outline-primary quick-btn", 
                                span("👥"), " Candidats"),
                    tags$button(id = "btn_vote", class = "btn btn-sm btn-outline-primary quick-btn", 
                                span("🗳️"), " Comment voter"),
                    tags$button(id = "btn_resultats", class = "btn btn-sm btn-outline-primary quick-btn", 
                                span("📊"), " Résultats")
                )
            )
        )
    )
)
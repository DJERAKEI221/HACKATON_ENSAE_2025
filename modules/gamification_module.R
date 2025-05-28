# Module de gamification pour le processus électoral
# Ce module ajoute des éléments ludiques pour encourager la participation

# UI du module de gamification
gamificationUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # CSS pour les éléments de gamification
    tags$style(HTML("
      /* Styles pour les badges */
      .badge-container {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        margin-top: 15px;
      }
      
      .badge-item {
        width: 100px;
        text-align: center;
        transition: all 0.3s ease;
      }
      
      .badge-item:hover {
        transform: scale(1.05);
      }
      
      .badge-icon {
        width: 80px;
        height: 80px;
        margin: 0 auto;
        background: linear-gradient(135deg, #f5f7fa, #e2e5f1);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        color: #8892b0;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        position: relative;
        overflow: hidden;
      }
      
      .badge-icon.earned {
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
        box-shadow: 0 4px 15px rgba(63, 81, 181, 0.3);
      }
      
      .badge-icon.locked {
        opacity: 0.6;
      }
      
      .badge-icon.locked:after {
        content: '🔒';
        position: absolute;
        font-size: 1.5rem;
        bottom: 5px;
        right: 5px;
      }
      
      .badge-name {
        margin-top: 8px;
        font-weight: 600;
        font-size: 0.8rem;
        color: #4a5568;
      }
      
      .badge-description {
        font-size: 0.7rem;
        color: #718096;
        margin-top: 4px;
      }
      
      /* Styles pour le tableau de classement */
      .leaderboard-container {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        margin-top: 20px;
      }
      
      .leaderboard-title {
        font-weight: 700;
        color: #2d3748;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid #e2e8f0;
      }
      
      .leaderboard-table {
        width: 100%;
      }
      
      .leaderboard-row {
        display: flex;
        align-items: center;
        padding: 10px 0;
        border-bottom: 1px solid #edf2f7;
        transition: background-color 0.2s ease;
      }
      
      .leaderboard-row:hover {
        background-color: #f7fafc;
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
      }
      
      .leaderboard-position.top-1 {
        background: linear-gradient(135deg, #FFD700, #FFA500);
        color: white;
      }
      
      .leaderboard-position.top-2 {
        background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
        color: white;
      }
      
      .leaderboard-position.top-3 {
        background: linear-gradient(135deg, #CD7F32, #8B4513);
        color: white;
      }
      
      .leaderboard-name {
        flex: 1;
        font-weight: 600;
        color: #2d3748;
      }
      
      .leaderboard-score {
        font-weight: 700;
        color: #3f51b5;
        display: flex;
        align-items: center;
      }
      
      .leaderboard-score i {
        margin-right: 5px;
      }
      
      /* Styles pour les jauges de progression */
      .progress-container {
        margin-top: 25px;
      }
      
      .progress-title {
        font-weight: 600;
        color: #2d3748;
        margin-bottom: 5px;
        display: flex;
        justify-content: space-between;
      }
      
      .progress-value {
        color: #3f51b5;
        font-weight: 700;
      }
      
      .custom-progress {
        height: 10px;
        background-color: #edf2f7;
        border-radius: 10px;
        overflow: hidden;
        margin-bottom: 20px;
      }
      
      .custom-progress-bar {
        height: 100%;
        border-radius: 10px;
        transition: width 1s ease;
        background: linear-gradient(90deg, #3f51b5, #303f9f);
      }
      
      /* Styles pour les animations et notifications de récompense */
      .reward-notification {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%) scale(0.8);
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        text-align: center;
        z-index: 9999;
        opacity: 0;
        transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        max-width: 400px;
        width: 90%;
      }
      
      .reward-notification.show {
        opacity: 1;
        transform: translate(-50%, -50%) scale(1);
      }
      
      .reward-notification .badge-icon {
        width: 120px;
        height: 120px;
        margin: 0 auto 20px;
        font-size: 3rem;
      }
      
      .reward-notification .reward-title {
        font-size: 1.5rem;
        font-weight: 700;
        margin-bottom: 10px;
      }
      
      .reward-notification .reward-description {
        font-size: 1rem;
        opacity: 0.9;
        margin-bottom: 20px;
      }
      
      .reward-close {
        background: rgba(255,255,255,0.2);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 50px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
      }
      
      .reward-close:hover {
        background: rgba(255,255,255,0.3);
      }
      
      /* Styles pour les points d'expérience */
      .xp-display {
        display: flex;
        align-items: center;
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
        padding: 8px 15px;
        border-radius: 50px;
        font-weight: 600;
        box-shadow: 0 4px 10px rgba(63, 81, 181, 0.3);
        position: fixed;
        top: 100px;
        right: 20px;
        z-index: 1000;
        transition: all 0.3s ease;
      }
      
      .xp-display:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 15px rgba(63, 81, 181, 0.4);
      }
      
      .xp-icon {
        margin-right: 8px;
        font-size: 1.2rem;
      }
      
      .xp-value {
        font-weight: 700;
      }
      
      /* Animation pour les points */
      .xp-popup {
        position: fixed;
        color: #3f51b5;
        font-weight: bold;
        pointer-events: none;
        z-index: 9999;
        font-size: 1.2rem;
        animation: xpFadeUp 1.5s forwards;
      }
      
      @keyframes xpFadeUp {
        0% { opacity: 0; transform: translateY(20px) scale(0.8); }
        20% { opacity: 1; transform: translateY(0) scale(1); }
        80% { opacity: 1; transform: translateY(-50px) scale(1); }
        100% { opacity: 0; transform: translateY(-80px) scale(0.8); }
      }
    ")),
    
    # JavaScript pour les animations et interactions
    tags$script(HTML("
      function showRewardNotification(title, description, icon) {
        // Créer la notification
        var notifId = 'reward-' + Math.random().toString(36).substr(2, 9);
        var html = 
          '<div id=\"' + notifId + '\" class=\"reward-notification\">' +
            '<div class=\"badge-icon earned\">' + icon + '</div>' +
            '<div class=\"reward-title\">' + title + '</div>' +
            '<div class=\"reward-description\">' + description + '</div>' +
            '<button class=\"reward-close\" onclick=\"hideRewardNotification(\\'' + notifId + '\\')\">' +
              'Génial !' +
            '</button>' +
          '</div>';
        
        $('body').append(html);
        
        // Afficher avec animation
        setTimeout(function() {
          $('#' + notifId).addClass('show');
        }, 100);
        
        // Jouer un son de récompense si disponible
        if (window.Audio) {
          try {
            var audio = new Audio('sounds/reward.mp3');
            audio.play();
          } catch(e) {
            console.log('Son non disponible');
          }
        }
        
        // Confettis (si la bibliothèque est chargée)
        if (typeof confetti !== 'undefined') {
          confetti({
            particleCount: 100,
            spread: 70,
            origin: { y: 0.6 }
          });
        }
      }
      
      function hideRewardNotification(id) {
        $('#' + id).removeClass('show');
        setTimeout(function() {
          $('#' + id).remove();
        }, 600);
      }
      
      function showXpGain(amount, x, y) {
        var id = 'xp-' + Math.random().toString(36).substr(2, 9);
        var html = '<div id=\"' + id + '\" class=\"xp-popup\">+' + amount + ' XP</div>';
        $('body').append(html);
        
        $('#' + id).css({
          'left': x + 'px',
          'top': y + 'px'
        });
        
        setTimeout(function() {
          $('#' + id).remove();
        }, 1500);
      }
      
      function updateProgress(id, value, max) {
        var percent = Math.min(100, Math.floor((value / max) * 100));
        $('#' + id + ' .custom-progress-bar').css('width', percent + '%');
        $('#' + id + ' .progress-value').text(value + ' / ' + max);
      }
      
      function animateBadgeEarned(id) {
        $('#' + id).removeClass('locked').addClass('earned');
        $('#' + id).parent().css('transform', 'scale(1.1)');
        
        setTimeout(function() {
          $('#' + id).parent().css('transform', 'scale(1)');
        }, 300);
      }
    ")),
    
    # Affichage des points XP
    div(id = ns("xp_display"), class = "xp-display",
      span(class = "xp-icon", icon("star")),
      span("XP: "), 
      span(id = ns("xp_value"), class = "xp-value", "0")
    ),
    
    # Conteneur pour les notifications de récompense
    div(id = ns("reward_container"), style = "display:none;")
  )
}

# Serveur pour le module de gamification
gamificationServer <- function(id, user_data, vote_data, participation_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Données réactives pour suivre les progrès
    user_progress <- reactiveVal(list(
      xp = 0,                  # Points d'expérience
      votes_cast = 0,          # Nombre de votes effectués
      badges_earned = list(),  # Badges gagnés
      participation_rate = 0,  # Taux de participation de la classe
      last_activity = NULL     # Dernière activité
    ))
    
    # Définition des badges
    badges <- list(
      first_vote = list(
        id = "first_vote",
        name = "Premier Vote",
        description = "A voté pour la première fois",
        icon = "🗳️",
        condition = function(progress) { progress$votes_cast >= 1 }
      ),
      all_positions = list(
        id = "all_positions",
        name = "Votant Complet",
        description = "A voté pour tous les postes disponibles",
        icon = "✅",
        condition = function(progress) { progress$votes_cast >= 9 }
      ),
      early_voter = list(
        id = "early_voter",
        name = "Votant Matinal",
        description = "A voté dans les premières heures de l'élection",
        icon = "🌅",
        condition = function(progress) { 
          !is.null(progress$first_vote_time) && 
          difftime(progress$first_vote_time, progress$election_start_time, units = "hours") <= 3 
        }
      ),
      participation_25 = list(
        id = "participation_25",
        name = "25% Participation",
        description = "La classe a atteint 25% de participation",
        icon = "📊",
        condition = function(progress) { progress$participation_rate >= 0.25 }
      ),
      participation_50 = list(
        id = "participation_50",
        name = "50% Participation",
        description = "La classe a atteint 50% de participation",
        icon = "📈",
        condition = function(progress) { progress$participation_rate >= 0.5 }
      ),
      participation_75 = list(
        id = "participation_75",
        name = "75% Participation",
        description = "La classe a atteint 75% de participation",
        icon = "🚀",
        condition = function(progress) { progress$participation_rate >= 0.75 }
      ),
      participation_100 = list(
        id = "participation_100",
        name = "100% Participation",
        description = "Toute la classe a voté!",
        icon = "🏆",
        condition = function(progress) { progress$participation_rate >= 1.0 }
      ),
      mobilisateur = list(
        id = "mobilisateur",
        name = "Mobilisateur",
        description = "5 étudiants ont voté après vous",
        icon = "👥",
        condition = function(progress) { progress$followers >= 5 }
      ),
      influenceur = list(
        id = "influenceur",
        name = "Influenceur",
        description = "10 étudiants ont voté après vous",
        icon = "🌟",
        condition = function(progress) { progress$followers >= 10 }
      )
    )
    
    # Actions qui donnent des points XP
    xp_actions <- list(
      vote = 10,              # Points pour chaque vote
      first_voter = 20,       # Premier votant d'une classe
      badge_earned = 15,      # Badge obtenu
      invite_friend = 5,      # Invitation d'un ami
      consecutive_days = 10,  # Connexion plusieurs jours consécutifs
      early_voter = 15,       # Vote dans les premières heures
      complete_profile = 5    # Profil complété
    )
    
    # Mise à jour des points XP
    observe({
      current_progress <- user_progress()
      session$sendCustomMessage("updateXpValue", list(
        id = ns("xp_value"),
        value = current_progress$xp
      ))
    })
    
    # Observer les votes pour mettre à jour la progression
    observe({
      votes <- vote_data()
      user_id <- user_data()$id
      
      if (!is.null(votes) && !is.null(user_id)) {
        # Filtrer les votes de l'utilisateur actuel
        user_votes <- votes[votes$voter_id == user_id, ]
        
        # Mise à jour du progrès
        current_progress <- user_progress()
        
        # Mettre à jour le nombre de votes
        new_votes_count <- nrow(user_votes)
        if (new_votes_count > current_progress$votes_cast) {
          # Ajouter des XP pour les nouveaux votes
          xp_gain <- (new_votes_count - current_progress$votes_cast) * xp_actions$vote
          
          # Animation des points XP
          if (xp_gain > 0) {
            # Position aléatoire pour l'animation
            x <- runif(1, 100, 300)
            y <- runif(1, 100, 300)
            session$sendCustomMessage("showXpGain", list(amount = xp_gain, x = x, y = y))
          }
          
          # Mettre à jour la progression
          current_progress$xp <- current_progress$xp + xp_gain
          current_progress$votes_cast <- new_votes_count
          
          # Vérifier s'il s'agit du premier vote
          if (new_votes_count == 1 && is.null(current_progress$first_vote_time)) {
            current_progress$first_vote_time <- Sys.time()
          }
          
          user_progress(current_progress)
        }
      }
    })
    
    # Observer le taux de participation
    observe({
      participation <- participation_data()
      
      if (!is.null(participation) && nrow(participation) > 0) {
        # Mettre à jour le taux de participation
        current_progress <- user_progress()
        
        # Récupérer la classe de l'utilisateur actuel
        user_class <- user_data()$class
        
        if (!is.null(user_class) && length(user_class) > 0 && !is.na(user_class) && 
            user_class %in% participation$classe) {
          new_rate <- participation$taux[participation$classe == user_class]
          
          if (!is.null(new_rate) && length(new_rate) > 0 && !is.na(new_rate)) {
            current_progress$participation_rate <- new_rate
            user_progress(current_progress)
          }
        }
      }
    })
    
    # Vérifier si de nouveaux badges sont débloqués
    observe({
      current_progress <- user_progress()
      if (is.null(current_progress)) return()
      
      new_badges <- list()
      
      # Vérifier chaque badge
      for (badge_id in names(badges)) {
        if (is.null(badge_id) || badge_id == "") next
        
        badge <- badges[[badge_id]]
        if (is.null(badge)) next
        
        # Si le badge n'est pas déjà gagné et la condition est remplie
        if (!(badge_id %in% names(current_progress$badges_earned))) {
          # Évaluation sécurisée de la condition
          condition_met <- tryCatch({
            badge$condition(current_progress)
          }, error = function(e) {
            warning(paste("Erreur lors de l'évaluation de la condition du badge:", e$message))
            FALSE
          })
          
          if (isTRUE(condition_met)) {
            # Ajouter le badge aux badges gagnés
            current_progress$badges_earned[[badge_id]] <- Sys.time()
            
            # Ajouter des XP pour le badge
            current_progress$xp <- current_progress$xp + xp_actions$badge_earned
            
            # Ajouter aux nouveaux badges pour notification
            new_badges[[badge_id]] <- badge
            
            # Mettre à jour le badge dans l'interface
            session$sendCustomMessage("animateBadgeEarned", list(id = ns(paste0("badge_", badge_id))))
          }
        }
      }
      
      # Si de nouveaux badges ont été gagnés
      if (length(new_badges) > 0) {
        # Mettre à jour la progression
        user_progress(current_progress)
        
        # Afficher les notifications pour les nouveaux badges
        for (badge_id in names(new_badges)) {
          if (is.null(badge_id) || badge_id == "") next
          
          badge <- new_badges[[badge_id]]
          if (is.null(badge)) next
          
          # Attendre un peu entre chaque notification
          invalidateLater(1000)
          
          # Afficher la notification de récompense
          session$sendCustomMessage("showRewardNotification", list(
            title = paste0("Badge débloqué: ", badge$name),
            description = badge$description,
            icon = badge$icon
          ))
        }
      }
    })
    
    # Rendre les badges disponibles
    renderBadges <- function() {
      all_badges <- list(
        first_vote = list(
          id = "first_vote",
          name = "Premier Vote",
          description = "A voté pour la première fois",
          icon = "🗳️",
          earned = TRUE
        ),
        all_positions = list(
          id = "all_positions",
          name = "Votant Complet",
          description = "A voté pour tous les postes disponibles",
          icon = "✅",
          earned = FALSE
        ),
        early_voter = list(
          id = "early_voter",
          name = "Votant Matinal",
          description = "A voté dans les premières heures",
          icon = "🌅",
          earned = TRUE
        ),
        participation_25 = list(
          id = "participation_25",
          name = "25% Participation",
          description = "La classe a atteint 25% de participation",
          icon = "📊",
          earned = TRUE
        ),
        participation_50 = list(
          id = "participation_50",
          name = "50% Participation",
          description = "La classe a atteint 50% de participation",
          icon = "📈",
          earned = FALSE
        ),
        participation_75 = list(
          id = "participation_75",
          name = "75% Participation",
          description = "La classe a atteint 75% de participation",
          icon = "🚀",
          earned = FALSE
        ),
        participation_100 = list(
          id = "participation_100",
          name = "100% Participation",
          description = "Toute la classe a voté!",
          icon = "🏆",
          earned = FALSE
        ),
        mobilisateur = list(
          id = "mobilisateur",
          name = "Mobilisateur",
          description = "5 étudiants ont voté après vous",
          icon = "👥",
          earned = TRUE
        ),
        influenceur = list(
          id = "influenceur",
          name = "Influenceur",
          description = "10 étudiants ont voté après vous",
          icon = "🌟",
          earned = FALSE
        )
      )
      
      HTML(paste0(
        '<div class="badge-container">',
        paste(sapply(names(all_badges), function(badge_id) {
          badge <- all_badges[[badge_id]]
          earned <- badge$earned
          
          paste0(
            '<div class="badge-item">',
            '  <div id="', ns(paste0("badge_", badge_id)), '" class="badge-icon ', ifelse(earned, 'earned', 'locked'), '">',
            badge$icon,
            '  </div>',
            '  <div class="badge-name">', badge$name, '</div>',
            '  <div class="badge-description">', badge$description, '</div>',
            '</div>'
          )
        }), collapse = ""),
        '</div>'
      ))
    }
    
    # Fonction pour créer une barre de progression
    createProgressBar <- function(id, title, value, max) {
      HTML(paste0(
        '<div class="progress-container" id="', ns(id), '">',
        '  <div class="progress-title">',
        '    <span>', title, '</span>',
        '    <span class="progress-value">', value, ' / ', max, '</span>',
        '  </div>',
        '  <div class="custom-progress">',
        '    <div class="custom-progress-bar" style="width: ', min(100, floor((value / max) * 100)), '%;"></div>',
        '  </div>',
        '</div>'
      ))
    }
    
    # Créer un tableau de classement
    createLeaderboard <- function(data) {
      # Trier les données par score décroissant
      data <- data[order(-data$score), ]
      
      HTML(paste0(
        '<div class="leaderboard-container">',
        '  <h3 class="leaderboard-title">Classement</h3>',
        '  <div class="leaderboard-table">',
        paste(sapply(1:min(nrow(data), 10), function(i) {
          paste0(
            '<div class="leaderboard-row">',
            '  <div class="leaderboard-position ', ifelse(i <= 3, paste0('top-', i), ''), '">', i, '</div>',
            '  <div class="leaderboard-name">', data$name[i], '</div>',
            '  <div class="leaderboard-score"><i class="fa fa-star"></i> ', data$score[i], ' XP</div>',
            '</div>'
          )
        }), collapse = ""),
        '  </div>',
        '</div>'
      ))
    }
    
    # Fonction pour générer le niveau de l'utilisateur
    getUserLevel <- function(xp) {
      # Formule simple pour déterminer le niveau
      level <- floor(sqrt(xp / 10))
      return(list(
        level = level,
        current_xp = xp,
        next_level_xp = (level + 1)^2 * 10,
        progress = (xp - level^2 * 10) / ((level + 1)^2 * 10 - level^2 * 10) * 100
      ))
    }
    
    # Fonctions exposées pour l'application principale
    list(
      addXp = function(amount, reason = NULL) {
        current_progress <- user_progress()
        current_progress$xp <- current_progress$xp + amount
        user_progress(current_progress)
        
        # Animer le gain XP
        x <- runif(1, 100, 300)
        y <- runif(1, 100, 300)
        session$sendCustomMessage("showXpGain", list(amount = amount, x = x, y = y))
      },
      recordActivity = function(activity_type, details = NULL) {
        current_progress <- user_progress()
        current_progress$last_activity <- list(
          type = activity_type,
          time = Sys.time(),
          details = details
        )
        user_progress(current_progress)
      },
      renderBadges = renderBadges,
      createProgressBar = createProgressBar,
      createLeaderboard = createLeaderboard,
      getUserLevel = function() {
        getUserLevel(user_progress()$xp)
      }
    )
  })
}

# Fonctions pour la page de profil gamifiée
gamificationProfileUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(width = 12,
      div(class = "profile-header",
        div(class = "profile-header-content",
          span(class = "profile-header-icon", icon("trophy", class = "fa-2x")),
          div(class = "profile-header-text",
            h2("Votre Profil de Participation"),
            p("Complétez les missions et gagnez des badges pour améliorer votre impact électoral!")
          )
        )
      )
    ),
    # Conteneur flexible pour les badges et statistiques côte à côte
    div(class = "flex-container",
      # Badges sur la gauche
      div(class = "badges-container",
        div(class = "profile-card",
          h3(
            span(class = "section-icon", icon("medal")),
            "Badges et Réalisations"
          ),
          uiOutput(ns("badges_section"))
        )
      ),
      # Statistiques sur la droite
      div(class = "stats-container",
        div(class = "profile-card stats-card",
          h3(
            span(class = "section-icon", icon("chart-line")),
            "Vos Statistiques"
          ),
          uiOutput(ns("user_level")),
          uiOutput(ns("progress_bars"))
        )
      )
    ),
    # Leaderboard en dessous
    column(width = 12, style = "margin-top: 30px;",
      div(class = "profile-card",
        h3(
          span(class = "section-icon", icon("ranking-star")),
          "Leaderboard de Participation"
        ),
        uiOutput(ns("leaderboard_section"))
      )
    )
  )
}

# Server pour la page de profil gamifiée
gamificationProfileServer <- function(id, gamification_module, votes_data, participation_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Afficher le niveau utilisateur et la barre de progression
    output$user_level <- renderUI({
      level_info <- gamification_module$getUserLevel()
      
      div(class = "user-level-container",
        div(class = "level-badge", level_info$level),
        div(class = "level-info",
          div(class = "level-title", paste0("Niveau ", level_info$level)),
          div(class = "level-progress-container",
            div(class = "level-progress-bar", 
                style = paste0("width: ", level_info$progress, "%"))
          ),
          div(class = "level-progress-text", 
              paste0(level_info$current_xp, " / ", level_info$next_level_xp, " XP"))
        )
      )
    })
    
    # Afficher les barres de progression
    output$progress_bars <- renderUI({
      votes <- votes_data()
      participation <- participation_data()
      
      # Vérifier si les données sont disponibles
      if (is.null(votes) || is.null(participation) || nrow(participation) == 0) {
        return(div(
          p("Données de participation non disponibles actuellement."),
          gamification_module$createProgressBar("vote_progress", "Votes Effectués", 0, 9)
        ))
      }
      
      # Vérifier si l'utilisateur est identifié
      user_id <- reactiveValuesToList(session$userData)$userId
      if (is.null(user_id)) {
        return(div(
          p("Veuillez vous connecter pour voir vos statistiques."),
          gamification_module$createProgressBar("vote_progress", "Votes Effectués", 0, 9)
        ))
      }
      
      # Nombre de votes de l'utilisateur (sécurisé)
      vote_count <- 0
      if (!is.null(votes) && "voter_id" %in% names(votes) && "position_id" %in% names(votes)) {
        vote_count <- length(unique(votes$position_id[votes$voter_id == user_id]))
      }
      
      # Taux de participation de la classe (sécurisé)
      participation_rate <- 0
      user_class <- reactiveValuesToList(session$userData)$class
      if (!is.null(user_class) && !is.null(participation) && "classe" %in% names(participation) && "taux" %in% names(participation)) {
        if (user_class %in% participation$classe) {
          class_rate <- participation$taux[participation$classe == user_class]
          if (length(class_rate) > 0 && !is.na(class_rate[1])) {
            participation_rate <- round(class_rate[1] * 100)
          }
        }
      }
      
      tagList(
        gamification_module$createProgressBar(
          "vote_progress", 
          "Votes Effectués", 
          vote_count, 
          9 # Nombre total de positions
        ),
        br(),
        gamification_module$createProgressBar(
          "participation_progress", 
          "Participation de la Classe", 
          participation_rate, 
          100
        )
      )
    })
    
    # Afficher les badges
    output$badges_section <- renderUI({
      gamification_module$renderBadges()
    })
    
    # Afficher le tableau de classement
    output$leaderboard_section <- renderUI({
      # Simuler des données de classement (à remplacer par de vraies données)
      leaderboard_data <- data.frame(
        name = c("Mamadou K.", "Aminata D.", "Ibrahima S.", "Fatou G.", "Jean P.",
                 "Marie C.", "Ahmed T.", "Sophie L.", "Omar D.", "Astou F."),
        score = c(320, 285, 260, 245, 230, 210, 195, 180, 175, 160)
      )
      
      gamification_module$createLeaderboard(leaderboard_data)
    })
  })
} 
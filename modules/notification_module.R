# Module pour les notifications en temps réel
# Ce module gère différents types de notifications pour l'application électorale

# UI du module de notification
notificationUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Zone invisible pour contenir les notifications
    div(id = ns("notification_area"), style = "display: none;"),
    
    # CSS pour les notifications personnalisées
    tags$style(HTML("
      .vote-notification {
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: linear-gradient(135deg, #3f51b5, #303f9f);
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        z-index: 9999;
        min-width: 300px;
        opacity: 0;
        transform: translateY(50px);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      }
      
      .vote-notification.show {
        opacity: 1;
        transform: translateY(0);
      }
      
      .vote-notification .close-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        background: rgba(255,255,255,0.2);
        border: none;
        color: white;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
      }
      
      .vote-notification .notification-icon {
        float: left;
        margin-right: 15px;
        background: rgba(255,255,255,0.2);
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .vote-notification .notification-content {
        margin-left: 55px;
      }
      
      .vote-notification .notification-title {
        font-weight: bold;
        margin-bottom: 5px;
      }
      
      .results-update-notification {
        background: linear-gradient(135deg, #4CAF50, #388E3C) !important;
      }
      
      .important-notification {
        background: linear-gradient(135deg, #FF5722, #E64A19) !important;
      }
      
      .countdown-timer {
        margin-top: 5px;
        height: 3px;
        background-color: rgba(255,255,255,0.5);
        width: 100%;
        position: relative;
      }
      
      .countdown-progress {
        position: absolute;
        top: 0;
        left: 0;
        height: 100%;
        background-color: white;
        width: 100%;
        transition: width linear;
      }
    ")),
    
    # JavaScript pour les notifications
    tags$script(HTML("
      function showVoteNotification(id, title, message, type, duration) {
        var notifId = 'notification-' + Math.random().toString(36).substr(2, 9);
        var notifClass = 'vote-notification';
        var iconHtml = '<i class=\"fa fa-bell\"></i>';
        
        if (type === 'vote') {
          notifClass += '';
          iconHtml = '<i class=\"fa fa-check-to-slot\"></i>';
        } else if (type === 'results') {
          notifClass += ' results-update-notification';
          iconHtml = '<i class=\"fa fa-chart-column\"></i>';
        } else if (type === 'important') {
          notifClass += ' important-notification';
          iconHtml = '<i class=\"fa fa-exclamation-circle\"></i>';
        }
        
        var html = 
          '<div id=\"' + notifId + '\" class=\"' + notifClass + '\">' +
            '<button class=\"close-btn\" onclick=\"dismissNotification(\'' + notifId + '\')\"><i class=\"fa fa-times\"></i></button>' +
            '<div class=\"notification-icon\">' + iconHtml + '</div>' +
            '<div class=\"notification-content\">' +
              '<div class=\"notification-title\">' + title + '</div>' +
              '<div class=\"notification-message\">' + message + '</div>' +
              '<div class=\"countdown-timer\"><div class=\"countdown-progress\"></div></div>' +
            '</div>' +
          '</div>';
        
        $('#' + id).append(html);
        
        setTimeout(function() {
          $('#' + notifId).addClass('show');
        }, 100);
        
        $('#' + notifId + ' .countdown-progress').css('transition', 'width ' + duration + 'ms linear');
        setTimeout(function() {
          $('#' + notifId + ' .countdown-progress').css('width', '0%');
        }, 100);
        
        setTimeout(function() {
          dismissNotification(notifId);
        }, duration);
        
        return notifId;
      }
      
      function dismissNotification(notifId) {
        $('#' + notifId).removeClass('show');
        setTimeout(function() {
          $('#' + notifId).remove();
        }, 400);
      }
    "))
  )
}

# Server du module de notification
notificationServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Fonction pour montrer une notification de vote
    showVoteNotification <- function(title, message, duration = 5000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showVoteNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "vote",
                                    duration = duration))
    }
    
    # Fonction pour montrer une notification de mise à jour des résultats
    showResultsNotification <- function(title, message, duration = 5000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showVoteNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "results",
                                    duration = duration))
    }
    
    # Fonction pour montrer une notification importante
    showImportantNotification <- function(title, message, duration = 7000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showVoteNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "important",
                                    duration = duration))
    }
    
    # Retourner les fonctions pour être utilisées par l'application principale
    list(
      showVoteNotification = showVoteNotification,
      showResultsNotification = showResultsNotification,
      showImportantNotification = showImportantNotification
    )
  })
} 
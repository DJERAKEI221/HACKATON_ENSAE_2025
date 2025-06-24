# Module pour les notifications en temps réel
# Ce module gère différents types de notifications pour l'application électorale

# UI du module de notification
notificationUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Zone invisible pour contenir les notifications
    div(id = ns("notification_area"), style = "display: none;"),
    
    # Centre de notifications
    div(id = ns("notification_center"), class = "notification-center", style = "display: none;",
        div(class = "notification-center-header",
            h4("Centre de notifications", class = "notification-center-title"),
            div(class = "notification-center-controls",
                actionButton(ns("mark_all_read"), "Tout marquer comme lu", class = "btn-outline-primary btn-sm"),
                actionButton(ns("close_center"), "×", class = "btn-close")
            )
        ),
        div(id = ns("notification_list"), class = "notification-list"),
        div(class = "notification-center-footer",
            actionButton(ns("clear_all"), "Effacer tout", class = "btn-outline-danger btn-sm")
        )
    ),
    
    # Bannière d'annonces globales
    div(id = ns("announcement_banner"), class = "announcement-banner", style = "display: none;",
        div(class = "announcement-content",
            div(class = "announcement-icon",
                icon("bullhorn")
            ),
            div(class = "announcement-text",
                div(class = "announcement-title"),
                div(class = "announcement-message")
            ),
            div(class = "announcement-actions",
                actionButton(ns("dismiss_announcement"), "×", class = "btn-close-announcement")
            )
        )
    ),
    
    # CSS pour les notifications personnalisées
    tags$style(HTML("
      /* Styles existants pour les notifications flottantes */
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
      
      .announcement-notification {
        background: linear-gradient(135deg, #9C27B0, #7B1FA2) !important;
      }
      
      .system-notification {
        background: linear-gradient(135deg, #607D8B, #455A64) !important;
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
      
      /* Styles pour le centre de notifications */
      .notification-center {
        position: fixed;
        top: 20px;
        right: 20px;
        width: 380px;
        max-height: 80vh;
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        z-index: 10000;
        opacity: 0;
        transform: translateX(100%);
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        overflow: hidden;
        display: flex;
        flex-direction: column;
      }
      
      .notification-center.show {
        opacity: 1;
        transform: translateX(0);
      }
      
      .notification-center-header {
        padding: 20px;
        border-bottom: 1px solid #e0e0e0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #f8f9fa;
      }
      
      .notification-center-title {
        margin: 0;
        font-size: 1.2rem;
        color: #2c3e50;
      }
      
      .notification-center-controls {
        display: flex;
        gap: 10px;
        align-items: center;
      }
      
      .btn-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #666;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .btn-close:hover {
        color: #333;
      }
      
      .notification-list {
        flex: 1;
        overflow-y: auto;
        max-height: 400px;
      }
      
      .notification-item {
        padding: 15px 20px;
        border-bottom: 1px solid #f0f0f0;
        transition: background-color 0.2s ease;
        cursor: pointer;
      }
      
      .notification-item:hover {
        background-color: #f8f9fa;
      }
      
      .notification-item.unread {
        background-color: #e3f2fd;
        border-left: 4px solid #2196F3;
      }
      
      .notification-item-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 5px;
      }
      
      .notification-item-title {
        font-weight: 600;
        color: #2c3e50;
        font-size: 0.9rem;
      }
      
      .notification-item-time {
        font-size: 0.8rem;
        color: #666;
      }
      
      .notification-item-message {
        color: #555;
        font-size: 0.85rem;
        line-height: 1.4;
      }
      
      .notification-item-icon {
        display: inline-block;
        margin-right: 8px;
        width: 16px;
        text-align: center;
      }
      
      .notification-center-footer {
        padding: 15px 20px;
        border-top: 1px solid #e0e0e0;
        background: #f8f9fa;
        text-align: center;
      }
      
      /* Bannière d'annonces */
      .announcement-banner {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        background: linear-gradient(135deg, #9C27B0, #7B1FA2);
        color: white;
        z-index: 9999;
        padding: 0;
        transform: translateY(-100%);
        transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      }
      
      .announcement-banner.show {
        transform: translateY(0);
      }
      
      .announcement-content {
        display: flex;
        align-items: center;
        padding: 15px 20px;
        max-width: 1200px;
        margin: 0 auto;
      }
      
      .announcement-icon {
        font-size: 1.5rem;
        margin-right: 15px;
        opacity: 0.9;
      }
      
      .announcement-text {
        flex: 1;
      }
      
      .announcement-title {
        font-weight: bold;
        font-size: 1.1rem;
        margin-bottom: 3px;
      }
      
      .announcement-message {
        font-size: 0.9rem;
        opacity: 0.9;
      }
      
      .announcement-actions {
        margin-left: 15px;
      }
      
      .btn-close-announcement {
        background: rgba(255,255,255,0.2);
        border: none;
        color: white;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 1.2rem;
      }
      
      .btn-close-announcement:hover {
        background: rgba(255,255,255,0.3);
      }
      
      /* Animations pour les notifications push */
      @keyframes bellShake {
        0%, 100% { transform: rotate(0deg); }
        25% { transform: rotate(-15deg); }
        75% { transform: rotate(15deg); }
      }
      
      .notification-bell.shake {
        animation: none;
      }
      
      /* Responsive design */
      @media (max-width: 768px) {
        .notification-center {
          width: 100%;
          max-width: 100%;
          right: 0;
          left: 0;
          top: 0;
          max-height: 100%;
          border-radius: 0;
        }
        
        .announcement-content {
          padding: 12px 15px;
          flex-direction: column;
          text-align: center;
        }
        
        .announcement-icon {
          margin-right: 0;
          margin-bottom: 10px;
        }
      }
    ")),
    
    # JavaScript pour les notifications
    tags$script(HTML("
      // Variables globales pour les notifications
      var notificationCount = 0;
      var notificationHistory = [];
      var isNotificationCenterOpen = false;
      
      // Fonction pour initialiser proprement les notifications
      window.initializeNotifications = function() {
        // Nettoyer complètement l'historique des notifications
        notificationHistory = [];
        notificationCount = 0;
        isNotificationCenterOpen = false;
        
        // Forcer la réinitialisation du badge
        var badge = $('.notification-badge');
        badge.text('0');
        badge.removeClass('show').css('display', 'none');
        
        // Mettre à jour l'affichage
        window.updateNotificationBadge();
        window.updateNotificationList();
        
        // S'assurer que le centre est fermé
        $('.notification-center').removeClass('show');
        
        console.log('Notifications initialisées - Badge devrait être à 0');
      };
      
      // Initialiser au chargement
      $(document).ready(function() {
        // Attendre un peu pour s'assurer que tout est chargé
        setTimeout(function() {
          window.initializeNotifications();
        }, 100);
        
        // Vérifier périodiquement s'il n'y a pas de notifications fantômes
        setTimeout(function() {
          if (notificationHistory.length === 0) {
            var badge = $('.notification-badge');
            badge.removeClass('show').css('display', 'none');
            console.log('Double vérification: badge caché car aucune notification');
          }
        }, 1000);
      });
      
      // Fonction principale pour afficher les notifications flottantes
      window.showVoteNotification = function(id, title, message, type, duration) {
        var notifId = 'notification-' + Math.random().toString(36).substr(2, 9);
        var notifClass = 'vote-notification';
        var iconHtml = '<i class=\"fa fa-bell\"></i>';
        
        if (type === 'vote') {
          iconHtml = '<i class=\"fa fa-check-to-slot\"></i>';
        } else if (type === 'results') {
          notifClass += ' results-update-notification';
          iconHtml = '<i class=\"fa fa-chart-column\"></i>';
        } else if (type === 'important') {
          notifClass += ' important-notification';
          iconHtml = '<i class=\"fa fa-exclamation-circle\"></i>';
        } else if (type === 'announcement') {
          notifClass += ' announcement-notification';
          iconHtml = '<i class=\"fa fa-bullhorn\"></i>';
        } else if (type === 'system') {
          notifClass += ' system-notification';
          iconHtml = '<i class=\"fa fa-cog\"></i>';
        }
        
        var html = 
          '<div id=\"' + notifId + '\" class=\"' + notifClass + '\">' +
            '<button class=\"close-btn\" onclick=\"window.dismissNotification(\\'' + notifId + '\\')\">' +
              '<i class=\"fa fa-times\"></i>' +
            '</button>' +
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
        
        // Ajouter à l'historique des notifications
        window.addToNotificationHistory(title, message, type);
        
        // Auto-dismiss après la durée spécifiée
        setTimeout(function() {
          window.dismissNotification(notifId);
        }, duration);
        
        // Faire sonner la cloche
        if (typeof window.shakeNotificationBell === 'function') {
          window.shakeNotificationBell();
        }
        
        return notifId;
      }
      
      // Fonction spéciale pour les notifications de bienvenue (sans historique)
      window.showWelcomeNotification = function(id, title, message, type, duration) {
        var notifId = 'notification-' + Math.random().toString(36).substr(2, 9);
        var notifClass = 'vote-notification important-notification';
        var iconHtml = '<i class=\"fa fa-user-check\"></i>';
        
        var html = 
          '<div id=\"' + notifId + '\" class=\"' + notifClass + '\">' +
            '<button class=\"close-btn\" onclick=\"window.dismissNotification(\\'' + notifId + '\\')\">' +
              '<i class=\"fa fa-times\"></i>' +
            '</button>' +
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
        
        // NOTE: On n'ajoute PAS à l'historique pour les notifications de bienvenue
        
        // Auto-dismiss après la durée spécifiée
        setTimeout(function() {
          window.dismissNotification(notifId);
        }, duration);
        
        return notifId;
      }
      
      window.dismissNotification = function(notifId) {
        $('#' + notifId).removeClass('show');
        setTimeout(function() {
          $('#' + notifId).remove();
        }, 400);
      }
      
      // Ajouter une notification à l'historique
      window.addToNotificationHistory = function(title, message, type) {
        var notification = {
          id: Date.now() + Math.random(),
          title: title,
          message: message,
          type: type,
          timestamp: new Date(),
          read: false
        };
        
        notificationHistory.unshift(notification);
        
        // Limiter l'historique à 50 notifications
        if (notificationHistory.length > 50) {
          notificationHistory = notificationHistory.slice(0, 50);
        }
        
        window.updateNotificationBadge();
        window.updateNotificationList();
      }
      
      // Mettre à jour le badge de notification
      window.updateNotificationBadge = function() {
        var unreadCount = notificationHistory.filter(n => !n.read).length;
        var badge = $('.notification-badge');
        
        // Debug pour voir ce qui se passe
        console.log('Mise à jour badge: ' + unreadCount + ' notifications non lues');
        console.log('Historique:', notificationHistory);
        
        if (unreadCount > 0) {
          badge.text(unreadCount > 99 ? '99+' : unreadCount);
          badge.addClass('show').css('display', 'flex');
        } else {
          badge.removeClass('show').css('display', 'none');
        }
      }
      
      // Mettre à jour la liste des notifications
      window.updateNotificationList = function() {
        var listContainer = $('.notification-list');
        listContainer.empty();
        
        if (notificationHistory.length === 0) {
          listContainer.html('<div style=\"padding: 40px; text-align: center; color: #666;\">'\n            + '<i class=\"fa fa-bell-slash\" style=\"font-size: 2rem; margin-bottom: 10px; display: block;\"></i>'\n            + 'Aucune notification'\n            + '</div>');
          return;
        }
        
        notificationHistory.forEach(function(notif) {
          var timeAgo = window.formatTimeAgo(notif.timestamp);
          var iconClass = window.getNotificationIcon(notif.type);
          var itemClass = 'notification-item' + (notif.read ? '' : ' unread');
          
          var itemHtml = 
            '<div class=\"' + itemClass + '\" onclick=\"window.markAsRead(' + notif.id + ')\">' +
              '<div class=\"notification-item-header\">' +
                '<div class=\"notification-item-title\">' +
                  '<span class=\"notification-item-icon\"><i class=\"' + iconClass + '\"></i></span>' +
                  notif.title +
                '</div>' +
                '<div class=\"notification-item-time\">' + timeAgo + '</div>' +
              '</div>' +
              '<div class=\"notification-item-message\">' + notif.message + '</div>' +
            '</div>';
          
          listContainer.append(itemHtml);
        });
      }
      
      // Obtenir l'icône pour chaque type de notification
      window.getNotificationIcon = function(type) {
        switch (type) {
          case 'vote': return 'fa fa-check-to-slot';
          case 'results': return 'fa fa-chart-column';
          case 'important': return 'fa fa-exclamation-circle';
          case 'announcement': return 'fa fa-bullhorn';
          case 'system': return 'fa fa-cog';
          default: return 'fa fa-bell';
        }
      }
      
      // Formater le temps relatif
      window.formatTimeAgo = function(timestamp) {
        var now = new Date();
        var diff = now - timestamp;
        var minutes = Math.floor(diff / 60000);
        var hours = Math.floor(minutes / 60);
        var days = Math.floor(hours / 24);
        
        if (days > 0) return days + 'j';
        if (hours > 0) return hours + 'h';
        if (minutes > 0) return minutes + 'min';
        return 'maintenant';
      }
      
      // Marquer une notification comme lue
      window.markAsRead = function(notifId) {
        var notif = notificationHistory.find(n => n.id === notifId);
        if (notif) {
                      notif.read = true;
          window.updateNotificationBadge();
          window.updateNotificationList();
        }
      }
      
      // Marquer toutes les notifications comme lues
      window.markAllAsRead = function() {
        notificationHistory.forEach(n => n.read = true);
        window.updateNotificationBadge();
        window.updateNotificationList();
      }
      
      // Effacer toutes les notifications
      window.clearAllNotifications = function() {
        notificationHistory = [];
        window.updateNotificationBadge();
        window.updateNotificationList();
      }
      
      // Ouvrir/fermer le centre de notifications
      window.toggleNotificationCenter = function() {
        var center = $('.notification-center');
        if (isNotificationCenterOpen) {
          center.removeClass('show');
          isNotificationCenterOpen = false;
        } else {
          center.addClass('show');
          window.updateNotificationList();
          isNotificationCenterOpen = true;
        }
      }
      
      // Faire trembler la cloche
      window.shakeNotificationBell = function() {
        var bell = $('.notification-bell');
        bell.addClass('shake');
        setTimeout(function() {
          bell.removeClass('shake');
        }, 500);
      }
      
      // Afficher une bannière d'annonce
      window.showAnnouncementBanner = function(title, message, priority) {
        var banner = $('.announcement-banner');
        var titleElement = banner.find('.announcement-title');
        var messageElement = banner.find('.announcement-message');
        
        titleElement.text(title);
        messageElement.text(message);
        
        // Adapter la couleur selon la priorité
        var bgColor = 'linear-gradient(135deg, #9C27B0, #7B1FA2)';
        if (priority === 'urgent') {
          bgColor = 'linear-gradient(135deg, #FF5722, #E64A19)';
        } else if (priority === 'info') {
          bgColor = 'linear-gradient(135deg, #2196F3, #1976D2)';
        }
        
        banner.css('background', bgColor);
        banner.addClass('show');
        
        // Ajuster le padding du body pour compenser la bannière
        setTimeout(function() {
          var bannerHeight = banner.outerHeight();
          $('body').css('padding-top', bannerHeight + 'px');
        }, 100);
      }
      
      // Masquer la bannière d'annonce
      window.hideAnnouncementBanner = function() {
        var banner = $('.announcement-banner');
        banner.removeClass('show');
        $('body').css('padding-top', '0');
      }
      
      // Fonction pour ajuster la position du bouton selon les autres éléments
      window.adjustNotificationButtonPosition = function() {
        var container = $('.notification-bell-container');
        // Chercher les éléments avec position fixed en bas à droite
        var fixedElements = $('*').filter(function() {
          var $el = $(this);
          if ($el.is(container)) return false;
          var css = $el.css(['position', 'bottom', 'right']);
          return css.position === 'fixed' && 
                 css.bottom && parseInt(css.bottom) < 150 && 
                 css.right && parseInt(css.right) < 100;
        });
        
        if (fixedElements.length > 0) {
          container.addClass('with-other-buttons');
          console.log('Autres boutons détectés, ajustement de la position');
        }
      };
      
      // Initialisation des événements
      $(document).ready(function() {
        // Ajuster la position au chargement
        setTimeout(window.adjustNotificationButtonPosition, 500);
        // Ouvrir le centre de notifications - utiliser l'ID avec namespace
        $(document).on('click', '[id$=\"open_center\"]', function(e) {
          e.preventDefault();
          e.stopPropagation();
          window.toggleNotificationCenter();
          return false;
        });
        
        // Fermer le centre de notifications
        $(document).on('click', '[id$=\"close_center\"]', function(e) {
          e.preventDefault();
          e.stopPropagation();
          window.toggleNotificationCenter();
          return false;
        });
        
        // Marquer tout comme lu
        $(document).on('click', '[id$=\"mark_all_read\"]', function(e) {
          e.preventDefault();
          e.stopPropagation();
          window.markAllAsRead();
          return false;
        });
        
        // Effacer tout
        $(document).on('click', '[id$=\"clear_all\"]', function(e) {
          e.preventDefault();
          e.stopPropagation();
          window.clearAllNotifications();
          return false;
        });
        
        // Fermer la bannière d'annonce
        $(document).on('click', '.btn-close-announcement', function() {
          window.hideAnnouncementBanner();
        });
        
        // Fermer le centre en cliquant à l'extérieur
        $(document).on('click', function(e) {
          if (isNotificationCenterOpen && 
              !$(e.target).closest('.notification-center').length && 
              !$(e.target).closest('.notification-bell-container').length) {
            window.toggleNotificationCenter();
          }
        });
      });
    "))
  )
}

# Server du module de notification
notificationServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Stockage des notifications persistantes
    notification_storage <- reactiveVal(list())
    
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
    
    # Fonction spéciale pour les notifications de bienvenue (n'ajoutent pas à l'historique)
    showWelcomeNotification <- function(title, message, duration = 5000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showWelcomeNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "welcome",
                                    duration = duration))
    }
    
    # Nouvelle fonction pour les annonces
    showAnnouncementNotification <- function(title, message, duration = 8000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showVoteNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "announcement",
                                    duration = duration))
    }
    
    # Nouvelle fonction pour les notifications système
    showSystemNotification <- function(title, message, duration = 6000) {
      notification_id <- paste0("notification_area")
      session$sendCustomMessage("showVoteNotification", 
                               list(id = ns(notification_id),
                                    title = title,
                                    message = message,
                                    type = "system",
                                    duration = duration))
    }
    
    # Fonction pour afficher une bannière d'annonce globale
    showGlobalAnnouncement <- function(title, message, priority = "normal") {
      session$sendCustomMessage("showAnnouncementBanner", 
                               list(title = title,
                                    message = message,
                                    priority = priority))
    }
    
    # Fonction pour masquer la bannière d'annonce
    hideGlobalAnnouncement <- function() {
      session$sendCustomMessage("hideAnnouncementBanner", list())
    }
    
    # Fonction pour envoyer une notification push (simulation)
    sendPushNotification <- function(title, message, type = "info", urgent = FALSE) {
      # Simuler l'envoi d'une notification push
      # Dans un vrai scénario, cela pourrait utiliser des services comme Firebase, Pusher, etc.
      
      # Afficher une notification locale
      if (urgent) {
        showImportantNotification(paste0("🚨 ", title), message, 10000)
      } else {
        showAnnouncementNotification(title, message)
      }
      
      # Log pour le débogage
      cat("Notification push envoyée:", title, "-", message, "\n")
    }
    
    # Les gestionnaires d'événements sont maintenant gérés côté JavaScript
    # pour éviter les conflits avec Shiny
    
    observeEvent(input$dismiss_announcement, {
      hideGlobalAnnouncement()
    })
    
    # Retourner les fonctions pour être utilisées par l'application principale
    list(
      showVoteNotification = showVoteNotification,
      showResultsNotification = showResultsNotification,
      showImportantNotification = showImportantNotification,
      showWelcomeNotification = showWelcomeNotification,
      showAnnouncementNotification = showAnnouncementNotification,
      showSystemNotification = showSystemNotification,
      showGlobalAnnouncement = showGlobalAnnouncement,
      hideGlobalAnnouncement = hideGlobalAnnouncement,
      sendPushNotification = sendPushNotification
    )
  })
} 
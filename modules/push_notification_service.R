# Service de notifications push automatiques
# Surveille les événements du système et envoie des notifications pertinentes

pushNotificationService <- function(notification_handlers, con) {
  
  # Variables pour stocker l'état précédent
  previous_vote_count <- 0
  notification_sent_thresholds <- list()
  
  # Fonction de surveillance
  monitor_system <- function() {
    # Surveiller les nouveaux votes
    current_vote_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM votes")$count
    
    if (current_vote_count > previous_vote_count) {
      new_votes <- current_vote_count - previous_vote_count
      
      if (new_votes == 1) {
        notification_handlers$showSystemNotification(
          "Nouveau vote enregistré",
          "Un électeur vient de voter !"
        )
      }
      
      previous_vote_count <<- current_vote_count
    }
    
    # Surveiller la participation
    total_voters <- dbGetQuery(con, "SELECT COUNT(*) as total FROM voters")$total
    if (total_voters > 0) {
      voted_count <- dbGetQuery(con, "SELECT COUNT(DISTINCT voter_id) as voted FROM votes")$voted
      participation_rate <- voted_count / total_voters
      
      # Seuils de participation
      thresholds <- c(0.25, 0.5, 0.75)
      
      for (threshold in thresholds) {
        threshold_key <- paste0("global_", threshold)
        
        if (participation_rate >= threshold && 
            !(threshold_key %in% names(notification_sent_thresholds))) {
          
          notification_sent_thresholds[[threshold_key]] <<- TRUE
          
          if (threshold == 0.25) {
            title <- "25% de participation atteinte"
            message <- "Un quart des électeurs ont voté !"
          } else if (threshold == 0.5) {
            title <- "50% de participation !"
            message <- "La moitié des électeurs ont voté !"
          } else if (threshold == 0.75) {
            title <- "75% de participation !"
            message <- "Participation exceptionnelle !"
          }
          
          notification_handlers$showGlobalAnnouncement(
            title, message, if (threshold >= 0.5) "important" else "normal"
          )
        }
      }
    }
  }
  
  list(monitor_system = monitor_system)
} 
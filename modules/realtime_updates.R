# Module pour les mises à jour en temps réel
# Ce module surveille les changements dans les données et déclenche des notifications

# Fonctions utilitaires pour détecter les mises à jour
detectVoteChange <- function(old_data, new_data) {
  if (is.null(old_data) || is.null(new_data)) {
    return(NULL)
  }
  
  # Si le nombre de votes a changé
  if (nrow(old_data) < nrow(new_data)) {
    # Récupérer les nouveaux votes
    new_votes <- new_data[!(new_data$id %in% old_data$id), ]
    return(new_votes)
  }
  
  return(NULL)
}

detectResultsChange <- function(old_results, new_results, threshold = 0.05) {
  if (is.null(old_results) || is.null(new_results)) {
    return(NULL)
  }
  
  changes <- list()
  
  # Vérifier les changements significatifs dans les résultats
  for (candidat in unique(new_results$candidat)) {
    old_pct <- old_results$pourcentage[old_results$candidat == candidat]
    new_pct <- new_results$pourcentage[new_results$candidat == candidat]
    
    if (length(old_pct) > 0 && length(new_pct) > 0) {
      # Si le pourcentage a changé significativement
      if (abs(old_pct - new_pct) >= threshold) {
        changes[[candidat]] <- list(
          candidat = candidat,
          old_pct = old_pct,
          new_pct = new_pct,
          diff = new_pct - old_pct
        )
      }
    }
  }
  
  if (length(changes) > 0) {
    return(changes)
  }
  
  return(NULL)
}

# Server du module de mises à jour en temps réel
realtimeUpdatesServer <- function(id, votes_data, results_data, notification_module) {
  moduleServer(id, function(input, output, session) {
    # Stockage des données précédentes
    previous_votes <- reactiveVal(NULL)
    previous_results <- reactiveVal(NULL)
    
    # Surveiller les changements dans les votes
    observe({
      current_votes <- votes_data()
      prev_votes <- previous_votes()
      
      # Vérifier s'il y a de nouveaux votes
      new_votes <- detectVoteChange(prev_votes, current_votes)
      
      if (!is.null(new_votes)) {
        # Pour chaque nouveau vote, envoyer une notification
        for (i in 1:nrow(new_votes)) {
          vote <- new_votes[i, ]
          
          # Créer un message de notification
          title <- "Nouveau vote enregistré"
          message <- paste0(
            "Un vote a été enregistré pour ", vote$classe, 
            " - Catégorie: ", vote$type_delegue
          )
          
          # Envoyer la notification
          notification_module$showVoteNotification(title, message)
        }
        
        # Mise à jour des votes précédents
        previous_votes(current_votes)
      } else if (is.null(prev_votes)) {
        # Initialiser les votes précédents
        previous_votes(current_votes)
      }
    })
    
    # Surveiller les changements dans les résultats
    observe({
      current_results <- results_data()
      prev_results <- previous_results()
      
      # Vérifier s'il y a des changements significatifs
      changes <- detectResultsChange(prev_results, current_results)
      
      if (!is.null(changes)) {
        # Pour chaque changement significatif, envoyer une notification
        for (candidat in names(changes)) {
          change <- changes[[candidat]]
          
          # Déterminer si c'est une augmentation ou une diminution
          direction <- if (change$diff > 0) "augmenté" else "diminué"
          
          # Créer un message de notification
          title <- "Mise à jour des résultats"
          message <- paste0(
            "Les résultats pour ", candidat, " ont ", direction, " de ",
            round(abs(change$diff) * 100), "% (", 
            round(change$old_pct * 100), "% → ", 
            round(change$new_pct * 100), "%)"
          )
          
          # Envoyer la notification
          notification_module$showResultsNotification(title, message)
        }
        
        # Mise à jour des résultats précédents
        previous_results(current_results)
      } else if (is.null(prev_results)) {
        # Initialiser les résultats précédents
        previous_results(current_results)
      }
    })
    
    # Fonction pour envoyer une notification concernant la participation
    notifyParticipation <- function(classe, participation) {
      # Seuils de participation pour les notifications
      thresholds <- c(0.25, 0.5, 0.75, 0.9)
      
      # Trouver le seuil dépassé
      for (threshold in thresholds) {
        if (participation >= threshold && (!is.null(previous_participation[[classe]]) && previous_participation[[classe]] < threshold)) {
          # Créer un message de notification
          title <- "Taux de participation atteint"
          message <- paste0(
            "La classe ", classe, " a atteint ", round(threshold * 100), 
            "% de participation !"
          )
          
          # Envoyer la notification
          notification_module$showImportantNotification(title, message)
          break
        }
      }
      
      # Mettre à jour la participation précédente
      previous_participation[[classe]] <- participation
    }
    
    # Variable pour stocker la participation précédente par classe
    previous_participation <- reactiveVal(list())
    
    # Rendre les fonctions disponibles pour l'application principale
    list(
      notifyParticipation = notifyParticipation
    )
  })
} 
# Script pour mettre à jour les photos des candidats Ben et Berete

library(DBI)
library(RSQLite)

# Connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Vérifier si la base de données existe
if (file.exists("data/elections.db")) {
  message("Base de données trouvée, mise à jour des photos...")
  
  # Vérifier que les images existent
  if (file.exists("www/images/pr_BEN.jpg") && file.exists("www/images/pr_Berete.jpg")) {
    message("Images trouvées, mise à jour des références...")
    
    # Mettre à jour les photos des candidats spécifiques
    dbExecute(con, "UPDATE candidates SET photo_url = 'images/pr_BEN.jpg' WHERE id = 1")
    dbExecute(con, "UPDATE candidates SET photo_url = 'images/pr_Berete.jpg' WHERE id = 2")
    
    # Vérifier les mises à jour
    candidates <- dbGetQuery(con, "SELECT id, name, photo_url FROM candidates WHERE id IN (1, 2)")
    print(candidates)
    
    message("Mise à jour terminée!")
  } else {
    message("ERREUR: Les fichiers images n'existent pas dans www/images/")
  }
} else {
  message("ERREUR: La base de données n'existe pas!")
}

# Fermer la connexion
dbDisconnect(con) 
# Script pour réparer les problèmes de connexion à la base de données
# Exécuter ce script après avoir fermé l'application Shiny

library(DBI)
library(RSQLite)

# Informations pour l'utilisateur
cat("Ce script vérifie et réinitialise la connexion à la base de données\n")
cat("--------------------------------------------------------------\n")

# Vérifier si le fichier de base de données existe
db_file <- "data/elections.db"
if (!file.exists(db_file)) {
  cat("ERREUR: Le fichier de base de données n'existe pas!\n")
  cat("Exécutez d'abord recreate_database.R pour créer la base de données.\n")
  quit(status = 1)
}

# Tenter de se connecter à la base de données
tryCatch({
  cat("Tentative de connexion à la base de données...\n")
  con <- dbConnect(RSQLite::SQLite(), db_file)
  
  # Vérifier si les tables existent
  tables <- dbListTables(con)
  if (length(tables) == 0) {
    cat("ATTENTION: La base de données existe mais ne contient aucune table!\n")
  } else {
    cat("Tables trouvées: ", paste(tables, collapse = ", "), "\n")
    
    # Vérifier les candidats
    candidates <- dbGetQuery(con, "SELECT id, name, position_id, photo_url FROM candidates ORDER BY id")
    cat("Nombre de candidats: ", nrow(candidates), "\n")
    print(candidates)
    
    # Vérifier que les candidats principaux existent
    ben <- dbGetQuery(con, "SELECT * FROM candidates WHERE name LIKE '%SOMA BEN%'")
    berete <- dbGetQuery(con, "SELECT * FROM candidates WHERE name LIKE '%BERETE%'")
    
    if (nrow(ben) == 0 || nrow(berete) == 0) {
      cat("ATTENTION: Les candidats principaux ne sont pas correctement configurés!\n")
      cat("Exécutez le script recreate_database.R pour recréer la base de données.\n")
    } else {
      cat("Candidats principaux trouvés et correctement configurés.\n")
    }
  }
  
  # Fermer la connexion
  cat("Fermeture de la connexion à la base de données...\n")
  dbDisconnect(con)
  
  cat("\nSUGGESTIONS POUR RÉSOUDRE LES PROBLÈMES DE CONNEXION:\n")
  cat("1. Assurez-vous que l'application utilise 'values$con' au lieu de 'con' pour les requêtes\n")
  cat("2. Ne jamais utiliser session$reload() qui cause une déconnexion\n")
  cat("3. Utilisez invalidateLater() pour rafraîchir l'interface sans recharger la session\n")
  
  cat("\nOpération terminée avec succès!\n")
}, error = function(e) {
  cat("ERREUR lors de la connexion à la base de données: ", e$message, "\n")
  cat("Essayez de supprimer le fichier data/elections.db et de recréer la base de données.\n")
})

cat("--------------------------------------------------------------\n")
cat("Pour appliquer les corrections à l'application:\n")
cat("1. Fermez l'application Shiny\n")
cat("2. Exécutez le script recreate_database.R\n")
cat("3. Relancez l'application\n") 